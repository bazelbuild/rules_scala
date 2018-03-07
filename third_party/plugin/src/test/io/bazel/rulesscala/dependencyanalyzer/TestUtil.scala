package third_party.plugin.src.test.io.bazel.rulesscala.dependencyanalyzer

import java.nio.file.Paths

import scala.reflect.internal.util.BatchSourceFile
import scala.reflect.io.VirtualDirectory
import scala.tools.cmd.CommandLineParser
import scala.tools.nsc.reporters.StoreReporter
import scala.tools.nsc.{CompilerCommand, Global, Settings}

object TestUtil {

  import scala.language.postfixOps

  final val defaultTarget = "//..."

  def run(code: String, withDirect: Map[String, String] = Map.empty, withIndirect: Map[String, String] = Map.empty): Seq[String] = {
    val compileOptions = Seq(
      constructParam("direct-jars", withDirect.keys),
      constructParam("direct-targets", withDirect.values),
      constructParam("indirect-jars", withIndirect.keys),
      constructParam("indirect-targets", withIndirect.values),
      constructParam("current-target", Seq(defaultTarget))
    ).mkString(" ")

    val extraClasspath = withDirect.keys ++ withIndirect.keys

    val reporter: StoreReporter = runCompilation(code, compileOptions, extraClasspath.toSeq)
    reporter.infos.collect({ case msg if msg.severity == reporter.ERROR => msg.msg }).toSeq
  }

  private def runCompilation(code: String, compileOptions: String, extraClasspath: Seq[String]) = {
    val fullClasspath: String = {
      val extraClasspathString = extraClasspath.mkString(":")
      if (toolboxClasspath.isEmpty) extraClasspathString
      else s"$toolboxClasspath:$extraClasspathString"
    }
    val basicOptions =
      createBasicCompileOptions(fullClasspath, toolboxPluginOptions)

    eval(code, s"$basicOptions $compileOptions")
  }

  /** Evaluate using global instance instead of toolbox because toolbox seems
    * to fail to typecheck code that comes from external dependencies. */
  private def eval(code: String, compileOptions: String = ""): StoreReporter = {
    // TODO: Optimize and cache global.
    val options = CommandLineParser.tokenize(compileOptions)
    val reporter = new StoreReporter()
    val settings = new Settings(println)
    val _ = new CompilerCommand(options, settings)
    settings.outputDirs.setSingleOutput(new VirtualDirectory("(memory)", None))
    val global = new Global(settings, reporter)
    val run = new global.Run
    val toCompile = new BatchSourceFile("<wrapper-init>", code)
    run.compileSources(List(toCompile))
    reporter
  }

  lazy val baseDir = System.getProperty("user.dir")

  lazy val toolboxClasspath: String =
    pathOf("scala.library.location")

  lazy val toolboxPluginOptions: String = {
    val jar = System.getProperty("plugin.jar.location")
    val start= jar.indexOf("/third_party/plugin")
    // this substring is needed due to issue: https://github.com/bazelbuild/bazel/issues/2475
    val jarInRelationToBaseDir = jar.substring(start, jar.length)
    val pluginPath = Paths.get(baseDir, jarInRelationToBaseDir).toAbsolutePath
    s"-Xplugin:${pluginPath} -Jdummy=${pluginPath.toFile.lastModified}"
  }

  lazy val guavaClasspath: String =
    pathOf("guava.jar.location")

  lazy val apacheCommonsClasspath: String =
    pathOf("apache.commons.jar.location")

  private def pathOf(jvmFlag: String) = {
    val jar = System.getProperty(jvmFlag)
    val libPath = Paths.get(baseDir, jar).toAbsolutePath
    libPath.toString
  }

  private def createBasicCompileOptions(classpath: String, usePluginOptions: String) =
    s"-classpath $classpath $usePluginOptions"

  private def constructParam(name: String, values: Iterable[String]) = {
    if (values.isEmpty) ""
    else s"-P:dependency-analyzer:$name:${values.mkString(":")}"
  }
}
