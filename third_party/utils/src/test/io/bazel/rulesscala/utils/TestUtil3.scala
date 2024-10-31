package io.bazel.rulesscala.utils

import dotty.tools.dotc.config.CommandLineParser
import dotty.tools.dotc.{Compiler, Driver}
import dotty.tools.dotc.core.Contexts.*
import dotty.tools.dotc.reporting.{StoreReporter, Diagnostic as CompilerDiagnostic}
import dotty.tools.dotc.util.{NoSourcePosition, SourceFile, SourcePosition as CompilerSourcePosition}
import dotty.tools.io.{Directory, PlainDirectory, VirtualDirectory}

import java.nio.file.{Path, Paths}

object TestUtil extends TestUtilCommon {
  class CompatSourcePosition(underlying: CompilerSourcePosition)(using Context)
      extends SourcePosition {
    override def isDefined = underlying.exists
    export underlying.{line, column}
  }

  override def runCompiler(
      code: String,
      extraClasspath: List[String] = List.empty,
      dependencyAnalyzerParamsOpt: Option[DependencyAnalyzerTestParams] = None,
      outputPathOpt: Option[Path] = None
  ): List[Diagnostic] = {
    val dependencyAnalyzerOptions = dependencyAnalyzerParamsOpt
      .map(getDependencyAnalyzerOptions)
      .map(CommandLineParser.tokenize)
      .getOrElse(Nil)
    val classPathOptions =
      CommandLineParser.tokenize(getClasspathArguments(extraClasspath))

    val extraCompilerOptions = dependencyAnalyzerOptions ++ classPathOptions
    val reporter = new TestReporter()
    given Context = {
      given ctx: FreshContext = (new ContextBase).initialCtx.fresh
      val fullClassPath =
        ctx.settings.classpath.value :+ extraClasspath ++ builtinClasspaths
          .filterNot(_.isEmpty)
      ctx
        .setReporter(reporter)
       .setSetting(ctx.settings.classpath, fullClassPath.mkString(":"))
       .setSetting(
         ctx.settings.outputDir,
         outputPathOpt
           .map(output => new PlainDirectory(new Directory(output)))
           .getOrElse(new VirtualDirectory("(memory)", None))
       )
        .setSettings(
          ctx.settings
            .processArguments(
              extraCompilerOptions,
              processAll = true,
              settingsState = ctx.settingsState
            )
            .sstate
        )
    }
    val compiler = new Compiler()
    val run = compiler.newRun
    try {
      run.compileSources(
        SourceFile.virtual(
          "scala_compiler_util_run_code.scala",
          code,
          maybeIncomplete = false
        ) :: Nil
      )
      // Follow Scala 2 semantic and handle only errors
      reporter.allErrors.map { err =>
        Diagnostic.Error(err.message, CompatSourcePosition(err.pos))
      }
    } catch {
      case err: Throwable =>
        // In case of compiler crash report a single error
        List(Diagnostic.Error(s"Compilation failed due to unhandled exception: ${err.getMessage}", CompatSourcePosition(NoSourcePosition)))
    }
    

  }

  override val builtinClasspaths: Seq[String] =
    pathOf("scala.library.location") :: pathOf("scala.library2.location") :: Nil
}

class TestReporter extends StoreReporter(null) {
  def storedInfos: List[CompilerDiagnostic] =
    println("stored::" + infos)
    if (infos != null) infos.toList else List()
}
