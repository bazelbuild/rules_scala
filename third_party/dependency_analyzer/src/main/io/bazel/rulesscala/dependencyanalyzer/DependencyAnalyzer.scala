package io.bazel.rulesscala.dependencyanalyzer

import java.util.jar.JarFile

import scala.reflect.io.AbstractFile
import scala.tools.nsc.plugins.{Plugin, PluginComponent}
import scala.tools.nsc.{Global, Phase}
import scala.util.control.NonFatal

class DependencyAnalyzer(val global: Global) extends Plugin {
  private val reporter = new Reporter(global)
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
    val usedJarsToPositions = findUsedJarsAndPositions
    val usedJarPathToPositions =
      if (!isWindows) {
        usedJarsToPositions.map { case (jar, pos) =>
          jar.path -> pos
        }
      } else {
        usedJarsToPositions.map { case (jar, pos) =>
          jar.path.replaceAll("\\\\", "/") -> pos
        }
      }

    if (settings.unusedDepsMode != AnalyzerMode.Off) {
      reportUnusedDepsFoundIn(usedJarPathToPositions)
    }

    if (settings.strictDepsMode != AnalyzerMode.Off) {
      reportIndirectTargetsFoundIn(usedJarPathToPositions)
    }
  }

  private def reportIndirectTargetsFoundIn(
    usedJarPathAndPositions: Map[String, global.Position]
  ): Unit = {
    val errors =
      usedJarPathAndPositions
        .filterNot { case (jarPath, _) =>
          settings.directTargetSet.jarSet.contains(jarPath)
        }
        .flatMap { case (jarPath, pos) =>
          settings.indirectTargetSet.targetFromJarOpt(jarPath)
            .map(target => tryResolveUnknownLabel(target, jarPath))
            .map { target =>
            target -> pos
          }
        }
        .filter {case (target, _) => !settings.localOnlyTracking || isLocalTarget(target)}
        .map { case (target, pos) =>
          val message =
            s"""Target '$target' is used but isn't explicitly declared, please add it to the deps.
               |You can use the following buildozer command:
               |buildozer 'add deps $target' ${settings.currentTarget}""".stripMargin
          message -> pos
        }

    warnOrError(settings.strictDepsMode, errors)
  }

  private def findManifestTargetLabel(jarPath: String): Option[String] = {
    try {
      val jar = new JarFile(jarPath)
      val targetLabel = Option(jar.getManifest)
        .flatMap(manifest => Option(manifest.getMainAttributes.getValue("Target-Label")))
      jar.close()
      targetLabel
    } catch {
      case NonFatal(e) =>
        println(s"Failed loading MANIFEST.MF from $jarPath")
        e.printStackTrace()
        None
    }
  }

  private def isUnknownLabel(label: String): Boolean = label.startsWith("Unknown label of")

  private def isJar(jarPath: String): Boolean = !jarPath.endsWith(".class")

  private def tryResolveUnknownLabel(label: String, jarPath: String): String = {
    if (isUnknownLabel(label) && isJar(jarPath))
      findManifestTargetLabel(jarPath).getOrElse(label)
    else
      label
  }

  private def reportUnusedDepsFoundIn(
    usedJarPathAndPositions: Map[String, global.Position]
  ): Unit = {
    val directJarPaths = settings.directTargetSet.jarSet


    val usedTargets =
      usedJarPathAndPositions
        .flatMap { case (jar, _) =>
          settings.directTargetSet.targetFromJarOpt(jar)
        }
        .toSet

    val unusedTargets = directJarPaths
      // This .get is safe because [jar] was gotten from [directJarPaths]
      // which is the set of keys of the direct targets.
      .filter(jar => !usedTargets.contains(settings.directTargetSet.targetFromJarOpt(jar).get))
      .flatMap(settings.directTargetSet.targetFromJarOpt)
      .diff(settings.ignoredUnusedDependencyTargets)

    val toWarnOrError =
      unusedTargets
        .filter(target => !settings.localOnlyTracking || isLocalTarget(target))
        .map { target =>
        val message =
          s"""Target '$target' is specified as a dependency to ${settings.currentTarget} but isn't used, please remove it from the deps.
             |You can use the following buildozer command:
             |buildozer 'remove deps $target' ${settings.currentTarget}
             |""".stripMargin
        (message, global.NoPosition: global.Position)
      }

    warnOrError(settings.unusedDepsMode, toWarnOrError.toMap)
  }

  private def isLocalTarget(label: String): Boolean = {
    !label.startsWith("@") && !isBrokenExternalLabel(label)
  }

  // workaround missing @ bug
  private def isBrokenExternalLabel(label: String) = !label.contains("/")

  private def warnOrError(
    analyzerMode: AnalyzerMode,
    errors: Map[String, global.Position]
  ): Unit = {
    val reportFunction: (String, global.Position) => Unit = analyzerMode match {
      case AnalyzerMode.Error => {
        case (message, pos) =>
          reporter.error(pos, message)
      }
      case AnalyzerMode.Warn => {
        case (message, pos) =>
          reporter.warning(pos, message)
      }
      case AnalyzerMode.Off => (_, _) => ()
    }

    errors.foreach { case (message, pos) =>
      reportFunction(message, pos)
    }
  }

  /**
   *
   * @return map of used jar file -> representative position in file where
   *         it was used
   */
  private def findUsedJarsAndPositions: Map[AbstractFile, global.Position] = {
    settings.dependencyTrackingMethod match {
      case DependencyTrackingMethod.HighLevel =>
        new HighLevelCrawlUsedJarFinder(global).findUsedJars
      case DependencyTrackingMethod.Ast =>
        new AstUsedJarFinder(global).findUsedJars
    }
  }
}
