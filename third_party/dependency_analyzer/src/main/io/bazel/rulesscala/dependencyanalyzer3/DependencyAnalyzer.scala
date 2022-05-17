package io.bazel.rulesscala.dependencyanalyzer

import dotty.tools.dotc.ast.Trees._
import dotty.tools.dotc.ast.tpd
import dotty.tools.dotc.core.Contexts.Context
import dotty.tools.dotc.util.{NoSourcePosition, SourcePosition}
import dotty.tools.dotc.plugins.{PluginPhase, StandardPlugin}
import dotty.tools.dotc.transform.{Pickler, Staging}
import dotty.tools.io.AbstractFile

class DependencyAnalyzer extends StandardPlugin {

  override val name: String = "dependency-analyzer"
  override val description: String =
    "Analyzes the used dependencies. Can check and warn or fail the " +
      "compilation for issues including not directly including " +
      "dependencies which are directly included in the code, or " +
      "including unused dependencies."

  def init(options: List[String]): List[PluginPhase] = {
    val settings = DependencyAnalyzerSettings.parseSettings(options = options, error = (_) => ())
    (new DependencyAnalyzerPhase(settings)) :: Nil
  }

  class DependencyAnalyzerPhase(settings: DependencyAnalyzerSettings) extends PluginPhase {
    import tpd.*

    val phaseName = "dependecy-analyzer-phase"

    override val runsAfter = Set(Pickler.name)
    override val runsBefore = Set(Staging.name)

    override def transformApply(tree: Apply)(implicit ctx: Context): Tree = {
      runAnalysis(tree)
      tree
    }

    private def runAnalysis(tree: Apply)(implicit ctx: Context): Unit = {
      val usedJarsToPositions = findUsedJarsAndPositions(tree)
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
        ???
      }
    }
    private val isWindows: Boolean = System.getProperty("os.name").toLowerCase.contains("windows")

    private def reportUnusedDepsFoundIn(usedJarPathAndPositions: Map[String, SourcePosition])(implicit ctx: Context): Unit = {
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
        unusedTargets.map { target =>
          val message =
            s"""Target '$target' is specified as a dependency to ${settings.currentTarget} but isn't used, please remove it from the deps.
               |You can use the following buildozer command:
               |buildozer 'remove deps $target' ${settings.currentTarget}
               |""".stripMargin
          (message, NoSourcePosition)
        }

      warnOrError(settings.unusedDepsMode, toWarnOrError.toMap)
    }

    private def warnOrError(analyzerMode: AnalyzerMode, errors: Map[String, SourcePosition])(implicit ctx: Context): Unit = {
      val reportFunction: (String, SourcePosition) => Unit = analyzerMode match {
        case AnalyzerMode.Error => {
          case (message, pos) => Reporter.error(pos, message)
        }
        case AnalyzerMode.Warn => {
          case (message, pos) => Reporter.warning(pos, message)
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
    private def findUsedJarsAndPositions(tree: Apply)(implicit ctx: Context): Map[AbstractFile, SourcePosition] = {
      settings.dependencyTrackingMethod match {
        case DependencyTrackingMethod.HighLevel => new HighLevelCrawlUsedJarFinder().findUsedJars(tree)
        case DependencyTrackingMethod.Ast => ???
      }
    }
  }
}