package third_party.dependency_analyzer.src.main.io.bazel.rulesscala.dependencyanalyzer

import scala.reflect.io.AbstractFile
import scala.tools.nsc.plugins.Plugin
import scala.tools.nsc.plugins.PluginComponent
import scala.tools.nsc.Global
import scala.tools.nsc.Phase

class DependencyAnalyzer(val global: Global) extends Plugin {

  override val name = "dependency-analyzer"
  override val description =
    "Analyzes the used dependencies. Can check and warn or fail the " +
      "compilation for issues including not directly including " +
      "dependencies which are directly included in the code, or " +
      "including unused dependencies."
  override val components = List[PluginComponent](Component)

  private val isWindows: Boolean = System.getProperty("os.name").toLowerCase.contains("windows")
  private var settings: DependencyAnalyzerSettings = null

  override def init(
    options: List[String],
    error: String => Unit
  ): Boolean = {
    settings = DependencyAnalyzerSettings.parseSettings(options = options, error = error)
    true
  }

  private object Component extends PluginComponent {
    val global: DependencyAnalyzer.this.global.type =
      DependencyAnalyzer.this.global

    override val runsAfter = List("jvm")

    val phaseName = DependencyAnalyzer.this.name

    override def newPhase(prev: Phase): StdPhase = new StdPhase(prev) {
      override def run(): Unit = {

        super.run()

        val usedJars = findUsedJars
        val usedJarPaths = if (!isWindows) usedJars.map(_.path) else usedJars.map(_.path.replaceAll("\\\\", "/"))

        if (settings.unusedDepsMode != AnalyzerMode.Off) {
          reportUnusedDepsFoundIn(usedJarPaths)
        }

        if (settings.strictDepsMode != AnalyzerMode.Off) {
          reportIndirectTargetsFoundIn(usedJarPaths)
        }
      }

      override def apply(unit: global.CompilationUnit): Unit = ()
    }

  }

  private def reportIndirectTargetsFoundIn(usedJarPaths: Set[String]): Unit = {
    val errors =
      usedJarPaths
        .filterNot(settings.directTargetSet.jarSet.contains)
        .flatMap(settings.indirectTargetSet.targetFromJarOpt)
        .map { target =>
          s"""Target '$target' is used but isn't explicitly declared, please add it to the deps.
             |You can use the following buildozer command:
             |buildozer 'add deps $target' ${settings.currentTarget}""".stripMargin
        }

    warnOrError(settings.strictDepsMode, errors)
  }

  private def reportUnusedDepsFoundIn(usedJarPaths: Set[String]): Unit = {
    val directJarPaths = settings.directTargetSet.jarSet

    val usedTargets =
      usedJarPaths.flatMap(settings.directTargetSet.targetFromJarOpt)

    val unusedTargets = directJarPaths
      // This .get is safe because [jar] was gotten from [directJarPaths]
      // which is the set of keys of the direct targets.
      .filter(jar => !usedTargets.contains(settings.directTargetSet.targetFromJarOpt(jar).get))
      .flatMap(settings.directTargetSet.targetFromJarOpt)
      .diff(settings.ignoredUnusedDependencyTargets)

    val toWarnOrError =
      unusedTargets.map { target =>
        s"""Target '$target' is specified as a dependency to ${settings.currentTarget} but isn't used, please remove it from the deps.
           |You can use the following buildozer command:
           |buildozer 'remove deps $target' ${settings.currentTarget}
           |""".stripMargin
      }

    warnOrError(settings.unusedDepsMode, toWarnOrError)
  }

  private def warnOrError(
    analyzerMode: AnalyzerMode,
    errors: Set[String]
  ): Unit = {
    val reportFunction: String => Unit = analyzerMode match {
      case AnalyzerMode.Error => global.reporter.error(global.NoPosition, _)
      case AnalyzerMode.Warn => global.reporter.warning(global.NoPosition, _)
      case AnalyzerMode.Off => _ => ()
    }

    errors.foreach(reportFunction)
  }

  private def findUsedJars: Set[AbstractFile] = {
    settings.dependencyTrackingMethod match {
      case DependencyTrackingMethod.HighLevel =>
        new HighLevelCrawlUsedJarFinder(global).findUsedJars
    }
  }
}
