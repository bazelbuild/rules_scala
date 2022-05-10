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

  private lazy val builtinClasspaths: List[String] =
    pathOf("scala.library.location") :: pathOf("scala.library2.location") :: Nil

  private def pathOf(jvmFlag: String) = {
    val jar = System.getProperty(jvmFlag)
    val libPath = Paths.get(baseDir, jar).toAbsolutePath
    libPath.toString
  }

  private lazy val baseDir = System.getProperty("user.dir")
}

class TestReporter extends StoreReporter(null) {
  def storedInfos: List[Diagnostic] = if (infos != null) infos.toList else List()
}
