package io.bazel.rulesscala.utils

import dotty.tools.dotc.Compiler
import dotty.tools.dotc.core.Contexts._
import dotty.tools.dotc.reporting.{Diagnostic, StoreReporter}
import dotty.tools.dotc.util.SourceFile
import dotty.tools.io.{AbstractFile, VirtualDirectory}

import java.nio.file.{Path, Paths}
import scala.util.control.NonFatal

object Scala3CompilerUtils {
  sealed trait CompileResult {
    def isSuccess: Boolean
  }
  case class Success() extends CompileResult{
    override def isSuccess: Boolean = true
  }
  case class Failure(errors: List[String]) extends CompileResult {
    override def isSuccess: Boolean = false
  }

  def runCompiler(
    code: String,
    extraClasspath: List[String] = List.empty,
    dependencyAnalyzerParamsOpt: Option[DependencyAnalyzerTestParams] = None,
    outputPathOpt: Option[Path] = None
  ): CompileResult = {
    val reporter = new TestReporter()

    implicit val context: FreshContext = (new ContextBase).initialCtx.fresh.setReporter(reporter)

    val fullClassPath = context.settings.classpath.value :: extraClasspath ::: builtinClasspaths.filterNot(_.isEmpty)

    context.setSetting(context.settings.classpath, fullClassPath.mkString(":"))
    val outputDir = outputPathOpt match {
      case Some(path) => AbstractFile.getDirectory(path)
      case None => new VirtualDirectory("")
    }
    context.setSetting(context.settings.outputDir, outputDir)
    context.setSetting(context.settings.plugin, List(toolboxPluginOptions))
    dependencyAnalyzerParamsOpt.foreach { options =>
      context.setSetting(context.settings.pluginOptions, getDependencyAnalyzerOptions(options))
    }

    val compiler = new Compiler()
    val run = compiler.newRun

    try {
      run.compileSources(SourceFile.virtual("scala_compiler_util_run_code.scala", code, maybeIncomplete = false) :: Nil)
      reporter.storedInfos match {
        case Nil => Success()
        case items => Failure(items.map(_.message))
      }
    } catch {
      case NonFatal(e) => Failure(List(e.getMessage))
    }
  }

  private def getDependencyAnalyzerOptions(params: DependencyAnalyzerTestParams): List[String] = {
    val argsForAnalyzer =
      List(
        "dependency-tracking-method" -> Seq(params.dependencyTrackingMethod.name),
        "current-target" -> Seq(defaultTarget),
        "unused-deps-mode" -> (if (params.unusedDeps) { Seq("error") } else { Seq() }),
        "strict-deps-mode" -> (if (params.strictDeps) { Seq("error") } else { Seq() }),
        "direct-jars" -> params.directJars,
        "direct-targets" -> params.directTargets,
        "indirect-jars" -> params.indirectJars,
        "indirect-targets" -> params.indirectTargets
      )
    val constructParam = constructPluginParam("dependency-analyzer") _
    argsForAnalyzer.map { case (k, v) =>
          constructParam(k, v)
        }
      .filter(_.nonEmpty)
  }

  private lazy val builtinClasspaths: List[String] =
    pathOf("scala.library.location") :: pathOf("scala.library2.location") :: Nil

  private def pathOf(jvmFlag: String) = {
    val jar = System.getProperty(jvmFlag)
    val libPath = Paths.get(baseDir, jar).toAbsolutePath
    libPath.toString
  }

  private lazy val baseDir = System.getProperty("user.dir")

  case class DependencyAnalyzerTestParams(
    dependencyTrackingMethod: DependencyTrackingMethod,
    strictDeps: Boolean = false,
    unusedDeps: Boolean = false,
    directJars: List[String] = List.empty,
    directTargets: List[String] = List.empty,
    indirectJars: List[String] = List.empty,
    indirectTargets: List[String] = List.empty
  )

  object DependencyTrackingMethod {
    case object HighLevel extends DependencyTrackingMethod("high-level")

    /**
     * Discovers dependencies by crawling the AST.
     */
    case object Ast extends DependencyTrackingMethod("ast")

    def parse(mode: String): Option[DependencyTrackingMethod] = {
      Seq(HighLevel, Ast).find(_.name == mode)
    }
  }

  sealed abstract class DependencyTrackingMethod(val name: String)

  lazy val apacheCommonsClasspath: String =
    pathOf("apache.commons.jar.location")

  def decodeLabel(targetLabel: String): String = targetLabel.replace(";", ":")

  def encodeLabel(targetLabel: String): String = targetLabel.replace(":", ";")

  final val defaultTarget = "//..."

  private def constructPluginParam(pluginName: String)(name: String, values: Iterable[String]): String = {
    if (values.isEmpty) ""
    else s"$pluginName:$name:${values.mkString(":")}"
  }

  private lazy val toolboxPluginOptions: String = {
    val jar = System.getProperty(s"plugin.jar.location")
    val start = jar.indexOf(s"/third_party/dependency_analyzer")
    val jarInRelationToBaseDir = jar.substring(start, jar.length)
    Paths.get(baseDir, jarInRelationToBaseDir).toAbsolutePath.toString
  }
}

class TestReporter extends StoreReporter(null) {
  def storedInfos: List[Diagnostic] = if (infos != null) infos.toList else List()
}
