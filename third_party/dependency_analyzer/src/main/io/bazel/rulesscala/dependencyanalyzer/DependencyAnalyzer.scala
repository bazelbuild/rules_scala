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
  override val components =
    List[PluginComponent](
      new AnalyzerComponent(
        runsAfterPhase = "typer",
        handles = DependencyTrackingMethod.Ast
      ),
      new AnalyzerComponent(
        runsAfterPhase = "jvm",
        handles = DependencyTrackingMethod.HighLevel
      )
    )

  private val isWindows: Boolean = System.getProperty("os.name").toLowerCase.contains("windows")
  private var settings: DependencyAnalyzerSettings = null

  override def init(
    options: List[String],
    error: String => Unit
  ): Boolean = {
    settings = DependencyAnalyzerSettings.parseSettings(options = options, error = error)
    true
  }

  private class AnalyzerComponent(
    // Typer seems to be the better method at least for AST - it seems like
    // some things get eliminated in later phases. However, due to backwards
    // compatibility we have to preserve using jvm for the high-level-crawl
    // dependency tracking method
    runsAfterPhase: String,
    handles: DependencyTrackingMethod
  ) extends PluginComponent {
    override val global: DependencyAnalyzer.this.global.type =
      DependencyAnalyzer.this.global

    override val runsAfter = List(runsAfterPhase)

    val phaseName = s"${DependencyAnalyzer.this.name}-post-$runsAfterPhase"

    override def newPhase(prev: Phase): StdPhase = new StdPhase(prev) {
      override def run(): Unit = {
        super.run()
        if (settings.dependencyTrackingMethod == handles) {
          runAnalysis()
        }
      }

      override def apply(unit: global.CompilationUnit): Unit = ()
    }
  }

  private def runAnalysis(): Unit = {
    val usedJars = findUsedJars
    val usedJarPaths = if (!isWindows) usedJars.map(_.path) else usedJars.map(_.path.replaceAll("\\\\", "/"))

    if (settings.unusedDepsMode != AnalyzerMode.Off) {
      reportUnusedDepsFoundIn(usedJarPaths)
    }

    if (settings.strictDepsMode != AnalyzerMode.Off) {
      reportIndirectTargetsFoundIn(usedJarPaths)
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
      case DependencyTrackingMethod.Ast =>
        new AstUsedJarFinder(global).findUsedJars
    }
  }
}
