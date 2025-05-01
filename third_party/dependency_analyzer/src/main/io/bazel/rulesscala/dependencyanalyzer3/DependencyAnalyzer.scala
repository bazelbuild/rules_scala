package io.bazel.rulesscala.dependencyanalyzer

import dotty.tools.dotc.ast.Trees.*
import dotty.tools.dotc.ast.tpd
import dotty.tools.dotc.core.Constants.Constant
import dotty.tools.dotc.core.Contexts.{Context, ctx}
import dotty.tools.dotc.core.Decorators.*
import dotty.tools.dotc.core.Phases
import dotty.tools.dotc.core.StdNames.*
import dotty.tools.dotc.core.Symbols.*
import dotty.tools.dotc.util.{NoSourcePosition, SrcPos}
import dotty.tools.dotc.plugins.{PluginPhase, StandardPlugin}
import dotty.tools.dotc.report
import dotty.tools.dotc.typer.Typer
import dotty.tools.backend.jvm
import dotty.tools.dotc.transform

import java.util.jar.JarFile
import dotty.tools.io.AbstractFile
import io.bazel.rulesscala.dependencyanalyzer.DependencyTrackingMethod.Ast
import io.bazel.rulesscala.scalac.reporter.DepsTrackingReporter

import java.util.Locale
import scala.jdk.CollectionConverters.*
import scala.util.control.NonFatal

class DependencyAnalyzer extends StandardPlugin:
  override val name: String = "dependency-analyzer"
  override val description: String =
    "Analyzes the used dependencies. Can check and warn or fail the " +
      "compilation for issues including not directly including " +
      "dependencies which are directly included in the code, or " +
      "including unused dependencies."

  override def init(options: List[String]): List[PluginPhase] = {
    given DependencyAnalyzerSettings = DependencyAnalyzerSettings.parseSettings(options, error = msg => println(msg))
    // We want to perform analysis after inlining and splicing (macro interpretation) is finished
    // transform.Splicing does not exist in Scala 3.1.3, use PickleQuotes (next phase) instead
    val inliningPhases = Set(transform.Inlining.name, transform.PickleQuotes.name)
    List(
      DependencyAnalyzerPhase(
        handles = DependencyTrackingMethod.Ast,
        runsAfter = inliningPhases, runsBefore = Set(transform.FirstTransform.name)),
      DependencyAnalyzerPhase(
        handles = DependencyTrackingMethod.AstPlus,
        runsAfter = inliningPhases, runsBefore = Set(transform.FirstTransform.name)),
      DependencyAnalyzerPhase(
        handles = DependencyTrackingMethod.HighLevel,
        runsAfter = Set(jvm.GenBCode.name), runsBefore = Set.empty)
    )
  }

class DependencyAnalyzerPhase(
 handles: DependencyTrackingMethod,
  override val runsAfter: Set[String],
  override val runsBefore: Set[String]
)(using settings: DependencyAnalyzerSettings)
    extends PluginPhase {
  private val isWindows: Boolean = System.getProperty("os.name")
    .toLowerCase(Locale.ROOT)
    .contains("windows")

  val phaseName = s"dependency-analyzer-$handles"

  override def isEnabled(using Context): Boolean = settings.dependencyTrackingMethod == handles

  override def run(using Context): Unit = runAnalysis()

  private def runAnalysis()(using Context): Unit = {
    val usedJarsToPositions = findUsedJarsAndPositions
    val usedJarPathToPositions = usedJarsToPositions.flatMap { (file, pos) =>
      val path =
        if isWindows then file.path.replaceAll("\\\\", "/")
        else file.path

      // Duplicate entries for .tasty / .class file entries
      // This would help when direct inputs (typically .class)
      // would not match detected usage (in 3.3 LTS typically .class, since 3.4 typically .tasty)
      val alternativeFiles =
        if path.isTastyFile then Seq(path, path.replace(".tasty", ".class"))
        else if path.isClassFile then Seq(path, path.replace(".class", ".tasty"))
        else Seq(path)

      alternativeFiles.map(_ -> pos)
    }

    ctx.reporter match
      case reporter: DepsTrackingReporter => reporter.registerAstUsedJars(usedJarPathToPositions.keys.toSet.asJava)
      case _ => ()

    if (settings.dependencyTrackingMethod != DependencyTrackingMethod.AstPlus) {
      if (settings.unusedDepsMode != AnalyzerMode.Off) {
        reportUnusedDepsFoundIn(usedJarPathToPositions)
      }

      if (settings.strictDepsMode != AnalyzerMode.Off) {
        reportIndirectTargetsFoundIn(usedJarPathToPositions)
      }
    }
  }

  private def reportIndirectTargetsFoundIn(usedJarPathAndPositions: Map[String, SrcPos])(using Context): Unit = {
    val errors = for
      (jarPath, pos) <- usedJarPathAndPositions
      if !settings.directTargetSet.jarSet.contains(jarPath)
      target <- settings.indirectTargetSet
        .targetFromJarOpt(jarPath)
        .map(target => tryResolveUnknownLabel(target, jarPath))
      message =
        s"""Target '$target' is used but isn't explicitly declared, please add it to the deps.
           |You can use the following buildozer command:
           |buildozer 'add deps $target' ${settings.currentTarget}""".stripMargin
    yield message -> pos

    warnOrError(settings.strictDepsMode, errors)
  }

  private def findManifestTargetLabel(jarPath: String): Option[String] = {
    scala.util.Using(new JarFile(jarPath)) { jar =>
      for manifest <- Option(jar.getManifest)
          attributes = manifest.getMainAttributes
          target <- Option(attributes.getValue("Target-Label"))
      yield target
    }.fold(
      err => {
        System.err.println(s"Failed loading MANIFEST.MF from $jarPath")
        err.printStackTrace()
        None
      },
      identity
    )
  }

  private def isUnknownLabel(label: String): Boolean = label.startsWith("Unknown label of")

  private def isJar(jarPath: String): Boolean = !(jarPath.isClassFile || jarPath.isTastyFile)

  private def tryResolveUnknownLabel(label: String, jarPath: String): String = {
    if (isUnknownLabel(label) && isJar(jarPath))
      findManifestTargetLabel(jarPath).getOrElse(label)
    else
      label
  }

  private def reportUnusedDepsFoundIn(usedJarPathAndPositions: Map[String, SrcPos])(using Context): Unit = {
    val directJarPaths = settings.directTargetSet.jarSet

    val usedTargets = usedJarPathAndPositions.keySet
      .flatMap(settings.directTargetSet.targetFromJarOpt)

    val unusedTargets = directJarPaths
      .filter(!settings.directTargetSet.targetFromJarOpt(_).exists(usedTargets.contains))
      .flatMap(settings.directTargetSet.targetFromJarOpt)
      .diff(settings.ignoredUnusedDependencyTargets)

    val toWarnOrError = unusedTargets.map { target =>
      val message =
        s"""Target '$target' is specified as a dependency to ${settings.currentTarget} but isn't used, please remove it from the deps.
           |You can use the following buildozer command:
           |buildozer 'remove deps $target' ${settings.currentTarget}
           |""".stripMargin
      (message, NoSourcePosition)
    }

    warnOrError(settings.unusedDepsMode, toWarnOrError.toMap)
  }

  private def warnOrError(analyzerMode: AnalyzerMode, errors: Map[String, SrcPos])(using Context): Unit = {
    val reportFunction: (String, SrcPos) => Unit = analyzerMode match {
      case AnalyzerMode.Error => report.error(_, _)
      case AnalyzerMode.Warn => report.warning(_, _)
      case AnalyzerMode.Off => (_, _) => ()
    }

    errors.foreach(reportFunction.tupled)
  }

  /**
   * @return
   * map of used jar file -> representative position in file where it was used
   */
  private def findUsedJarsAndPositions(using Context): Map[AbstractFile, SrcPos] =
    settings.dependencyTrackingMethod match {
      case DependencyTrackingMethod.HighLevel => HighLevelCrawlUsedJarFinder().findUsedJars
      case DependencyTrackingMethod.Ast => AstUsedJarFinder().findUsedJars
      case DependencyTrackingMethod.AstPlus => AstUsedJarFinder().findUsedJars
    }
}
