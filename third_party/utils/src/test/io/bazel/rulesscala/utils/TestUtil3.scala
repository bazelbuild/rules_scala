package io.bazel.rulesscala.utils

import dotty.tools.dotc.Compiler
import dotty.tools.dotc.core.Contexts._
import dotty.tools.dotc.reporting.Diagnostic
import dotty.tools.dotc.util.SourceFile

import java.nio.file.{Path, Paths}

object TestUtil3 {
  final val defaultTarget = "//..."

  case class DependencyAnalyzerTestParams(
    //dependencyTrackingMethod: DependencyTrackingMethod,
    strictDeps: Boolean = false,
    unusedDeps: Boolean = false,
    directJars: List[String] = List.empty,
    directTargets: List[String] = List.empty,
    indirectJars: List[String] = List.empty,
    indirectTargets: List[String] = List.empty
  )

  /**
   * Runs the compiler on a piece of code.
   *
   * @param dependencyAnalyzerParamsOpt If set, includes the dependency analyzer
   *                                    plugin with the provided parameters
   * @param outputPathOpt If non-None, a directory to output the files in
   * @return list of errors returned by the compiler
   */
  def runCompiler(
    code: String,
    extraClasspath: List[String] = List.empty,
    dependencyAnalyzerParamsOpt: Option[DependencyAnalyzerTestParams] = None,
    outputPathOpt: Option[Path] = None
  ): List[Diagnostic] = {
    val reporter = new TestReporter()
    implicit val ctx = (new ContextBase).initialCtx.fresh
      .setReporter(reporter)
      .setDebug
    val fullClassPath =
      (List(getClasspathArguments(extraClasspath)) :+ ctx.settings.classpath.value).mkString(":")
    ctx.setSetting(ctx.settings.classpath, fullClassPath)

    val compiler = new Compiler()
    val run = compiler.newRun
    run.compileSources(List(SourceFile.virtual("some.scala", code, false)))
    run.printSummary()

    reporter.storedInfos
  }

  private def getClasspathArguments(extraClasspath: List[String]): String = {
    val classpathEntries = {
      val builtinClassPaths = builtinClasspaths.filterNot(_.isEmpty)
      extraClasspath ++ builtinClassPaths
    }
    if (classpathEntries.isEmpty) {
      ""
    } else {
      s"${classpathEntries.mkString(":")}"
    }
  }

  private lazy val builtinClasspaths: Vector[String] =
    Vector(
      pathOf("scala.library.location"),
      pathOf("scala.library2.location")
    )

  lazy val guavaClasspath: String =
    pathOf("guava.jar.location")

  lazy val apacheCommonsClasspath: String =
    pathOf("apache.commons.jar.location")

  private def pathOf(jvmFlag: String) = {
    val jar = System.getProperty(jvmFlag)
    val libPath = Paths.get(baseDir, jar).toAbsolutePath
    libPath.toString
  }

  private lazy val baseDir = System.getProperty("user.dir")


}

import dotty.tools.dotc.reporting.StoreReporter

class TestReporter extends StoreReporter(null) {
  def storedInfos = if(infos != null) infos.toList else List()
}