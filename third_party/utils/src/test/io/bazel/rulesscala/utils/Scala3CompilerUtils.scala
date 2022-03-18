package io.bazel.rulesscala.utils

import dotty.tools.dotc.Compiler
import dotty.tools.dotc.core.Contexts._
import dotty.tools.dotc.reporting.Diagnostic
import dotty.tools.dotc.util.SourceFile

import java.nio.file.Paths

object Scala3CompilerUtils {
  def runCompiler(
    code: String,
    extraClasspath: List[String] = List.empty,
  ): List[Diagnostic] = {
    val reporter = new TestReporter()

    implicit val context: FreshContext = (new ContextBase).initialCtx.fresh.setReporter(reporter)

    val fullClassPath =
      builtinClasspaths.filterNot(_.isEmpty) ++
        extraClasspath :+
        context.settings.classpath.value

    context.setSetting(context.settings.classpath, fullClassPath.mkString(":"))

    val compiler = new Compiler()
    val run = compiler.newRun
    run.compileSources(List(SourceFile.virtual("code.scala", code, maybeIncomplete = false)))

    reporter.storedInfos
  }

  private lazy val builtinClasspaths: Vector[String] =
    Vector(
      pathOf("scala.library.location"),
      pathOf("scala.library2.location")
    )

  private def pathOf(jvmFlag: String) = {
    val jar = System.getProperty(jvmFlag)
    val libPath = Paths.get(baseDir, jar).toAbsolutePath
    libPath.toString
  }

  private lazy val baseDir = System.getProperty("user.dir")
}

import dotty.tools.dotc.reporting.StoreReporter

class TestReporter extends StoreReporter(null) {
  def storedInfos: List[Diagnostic] = if (infos != null) infos.toList else List()
}
