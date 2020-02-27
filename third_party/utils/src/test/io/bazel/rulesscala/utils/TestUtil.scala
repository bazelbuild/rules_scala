package third_party.utils.src.test.io.bazel.rulesscala.utils

import java.nio.file.Path
import java.nio.file.Paths
import scala.reflect.internal.util.BatchSourceFile
import scala.reflect.io.AbstractFile
import scala.reflect.io.Directory
import scala.reflect.io.PlainDirectory
import scala.reflect.io.VirtualDirectory
import scala.tools.cmd.CommandLineParser
import scala.tools.nsc.CompilerCommand
import scala.tools.nsc.Global
import scala.tools.nsc.Settings
import scala.tools.nsc.reporters.StoreReporter
import third_party.dependency_analyzer.src.main.io.bazel.rulesscala.dependencyanalyzer.DependencyTrackingMethod

object TestUtil {
  final val defaultTarget = "//..."

  private def constructPluginParam(pluginName: String)(name: String, values: Iterable[String]): String = {
    if (values.isEmpty) ""
    else s"-P:$pluginName:$name:${values.mkString(":")}"
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

  private def getDependencyAnalyzerOptions(params: DependencyAnalyzerTestParams): String = {
    val argsForAnalyzer =
      List(
        "dependency-tracking-method" -> Seq(params.dependencyTrackingMethod.name),
        "current-target" -> Seq(TestUtil.defaultTarget),
        "unused-deps-mode" -> (if (params.unusedDeps) { Seq("error") } else { Seq() }),
        "strict-deps-mode" -> (if (params.strictDeps) { Seq("error") } else { Seq() }),
        "direct-jars" -> params.directJars,
        "direct-targets" -> params.directTargets,
        "indirect-jars" -> params.indirectJars,
        "indirect-targets" -> params.indirectTargets
      )
    val constructParam = TestUtil.constructPluginParam("dependency-analyzer") _
    val argsForAnalyzerString =
      argsForAnalyzer
        .map { case (k, v) =>
          constructParam(k, v)
        }
        .mkString(" ")
    s"$argsForAnalyzerString $toolboxPluginOptions"
  }

  private def getClasspathArguments(extraClasspath: List[String]): String = {
    val classpathEntries = {
      val builtinClassPaths = builtinClasspaths.filterNot(_.isEmpty)
      extraClasspath ++ builtinClassPaths
    }
    if (classpathEntries.isEmpty) {
      ""
    } else {
      s"-classpath ${classpathEntries.mkString(":")}"
    }
  }

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
  ): List[StoreReporter#Info] = {
    val dependencyAnalyzerOptions =
      dependencyAnalyzerParamsOpt
        .map(getDependencyAnalyzerOptions)
        .getOrElse("")
    val classPathOptions = getClasspathArguments(extraClasspath)
    val compileOptions = s"$dependencyAnalyzerOptions $classPathOptions"
    val output =
      outputPathOpt
        .map(output => new PlainDirectory(new Directory(output.toFile)))
        .getOrElse(new VirtualDirectory("(memory)", None))
    eval(code = code, compileOptions = compileOptions, output = output)
  }

  private def eval(
    code: String,
    compileOptions: String,
    output: AbstractFile
  ): List[StoreReporter#Info] = {
    // TODO: Optimize and cache global.
    val options = CommandLineParser.tokenize(compileOptions)
    val reporter = new StoreReporter()
    val settings = new Settings(println)
    val _ = new CompilerCommand(options, settings)
    settings.outputDirs.setSingleOutput(output)

    // Evaluate using global instance instead of toolbox because toolbox seems
    // to fail to typecheck code that comes from external dependencies.
    val global = new Global(settings, reporter)

    val run = new global.Run

    // It is important that the source name when compiling code
    // looks like a valid scala file -
    // this causes the compiler to report positions correctly. And
    // tests verify that positions are reported successfully.
    val toCompile = new BatchSourceFile("CompiledCode.scala", code)
    run.compileSources(List(toCompile))
    reporter.infos.filter(_.severity == reporter.ERROR).toList
  }

  private lazy val baseDir = System.getProperty("user.dir")

  private lazy val builtinClasspaths: Vector[String] =
    Vector(
      pathOf("scala.library.location"),
      pathOf("scala.reflect.location")
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

  def decodeLabel(targetLabel: String): String = targetLabel.replace(";", ":")

  def encodeLabel(targetLabel: String): String = targetLabel.replace(":", ";")
}