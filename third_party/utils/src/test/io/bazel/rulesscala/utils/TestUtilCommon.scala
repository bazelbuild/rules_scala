package io.bazel.rulesscala.utils

import java.nio.file.{Path, Paths}
import io.bazel.rulesscala.dependencyanalyzer.DependencyTrackingMethod

trait TestUtilCommon {
  trait SourcePosition {
    def isDefined: Boolean

    def line: Int

    def column: Int
  }

  class Diagnostic(val msg: String, val pos: SourcePosition)

  object Diagnostic {
    case class Error(message: String, srcPos: SourcePosition) extends Diagnostic(message, srcPos)

    case class Warning(message: String, srcPos: SourcePosition) extends Diagnostic(message, srcPos)

    case class Info(message: String, srcPos: SourcePosition) extends Diagnostic(message, srcPos)
  }

  /**
   * Runs the compiler on a piece of code.
   *
   * @param dependencyAnalyzerParamsOpt If set, includes the dependency analyzer
   *                                    plugin with the provided parameters
   * @param outputPathOpt               If non-None, a directory to output the files in
   * @return list of errors returned by the compiler
   */
  def runCompiler(
                   code: String,
                   extraClasspath: List[String] = List.empty,
                   dependencyAnalyzerParamsOpt: Option[DependencyAnalyzerTestParams] = None,
                   outputPathOpt: Option[Path] = None
                 ): List[Diagnostic]

  def builtinClasspaths: Seq[String]

  final val defaultTarget = "//..."

  val isWindows: Boolean = System.getProperty("os.name").toLowerCase.contains("windows")

  //Backslashes used as escape, so paths should use forward slashes to simulate the scalacworker.
  private def normalizePath(s: String): String =
    if (isWindows) s.replace('\\', '/') else s

  private def constructPluginParam(pluginName: String)(name: String, values: Iterable[String]): String = {
    //Using ';' as a param value delimiter, and then need to escape any ';' thats in a param's value
    if (values.isEmpty) ""
    else s"-P:$pluginName:$name:${values.map(s => s.replace(";", "\\;")).mkString(";")}"
  }

  private lazy val toolboxPluginOptions: String = {
    val jar = System.getProperty(s"plugin.jar.location")
    val start = jar.indexOf(s"/third_party/dependency_analyzer")
    // this substring is needed due to issue: https://github.com/bazelbuild/bazel/issues/2475
    val jarInRelationToBaseDir = jar.substring(start, jar.length)
    val pluginPath = Paths.get(baseDir, jarInRelationToBaseDir).toAbsolutePath
    s"-Xplugin:$pluginPath -Jdummy=${pluginPath.toFile.lastModified}"
  }

  case class DependencyAnalyzerTestParams(
                                           dependencyTrackingMethod: DependencyTrackingMethod,
                                           strictDeps: Boolean = false,
                                           unusedDeps: Boolean = false,
                                           directJars: List[String] = List.empty,
                                           directTargets: List[String] = List.empty,
                                           indirectJars: List[String] = List.empty,
                                           indirectTargets: List[String] = List.empty
                                         )

  protected def getDependencyAnalyzerOptions(params: DependencyAnalyzerTestParams): String = {
    val argsForAnalyzer =
      List(
        "dependency-tracking-method" -> Seq(params.dependencyTrackingMethod.name),
        "current-target" -> Seq(defaultTarget),
        "unused-deps-mode" -> (if (params.unusedDeps) {
          Seq("error")
        } else {
          Seq()
        }),
        "strict-deps-mode" -> (if (params.strictDeps) {
          Seq("error")
        } else {
          Seq()
        }),
        "direct-jars" -> params.directJars.map(normalizePath),
        "direct-targets" -> params.directTargets,
        "indirect-jars" -> params.indirectJars.map(normalizePath),
        "indirect-targets" -> params.indirectTargets
      )
    val argsForAnalyzerString =
      argsForAnalyzer
        .map { case (k, v) =>
          constructPluginParam("dependency-analyzer")(k, v)
        }
        .mkString(" ")
    s"$argsForAnalyzerString $toolboxPluginOptions"
  }

  protected def getClasspathArguments(extraClasspath: List[String]): String = {
    val classpathEntries = {
      val builtinClassPaths = builtinClasspaths.filterNot(_.isEmpty)
      extraClasspath ++ builtinClassPaths
    }
    if (classpathEntries.isEmpty) ""
    else s"-classpath ${classpathEntries.map(normalizePath).mkString(java.io.File.pathSeparator)}"
  }

  private lazy val baseDir = System.getProperty("user.dir")

  lazy val guavaClasspath: String = pathOf("guava.jar.location")
  lazy val apacheCommonsClasspath: String = pathOf("apache.commons.jar.location")

  protected def pathOf(jvmFlag: String) = {
    val jar = System.getProperty(jvmFlag)
    val libPath = Paths.get(baseDir, jar).toAbsolutePath
    libPath.toString
  }
}
