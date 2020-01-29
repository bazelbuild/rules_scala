package third_party.utils.src.test.io.bazel.rules_scala.utils

import java.nio.file.Paths

import scala.reflect.internal.util.BatchSourceFile
import scala.reflect.io.VirtualDirectory
import scala.tools.cmd.CommandLineParser
import scala.tools.nsc.reporters.StoreReporter
import scala.tools.nsc.{CompilerCommand, Global, Settings}

object TestUtil {

  import scala.language.postfixOps

  final val defaultTarget = "//..."

  def constructPluginParam(pluginName: String)(name: String, values: Iterable[String]): String = {
    if (values.isEmpty) ""
    else s"-P:$pluginName:$name:${values.mkString(":")}"
  }

  def runCompiler(code: String, compileOptions: String, extraClasspath: List[String], toolboxPluginOptions: String): List[String] = {
    val fullCompileOptions: String = getCompileOptions(code, compileOptions, extraClasspath, toolboxPluginOptions)
    val reporter: StoreReporter =  eval(code, fullCompileOptions)
    reporter.infos.collect({ case msg if msg.severity == reporter.ERROR => msg.msg }).toList
  }

  private def getCompileOptions(code: String, compileOptions: String, extraClasspath: Seq[String], toolboxPluginOptions: String): String = {
    val fullClasspath: String = {
      val extraClasspathString = extraClasspath.mkString(":")
      if (toolboxClasspath.isEmpty) extraClasspathString
      else s"$toolboxClasspath:$extraClasspathString"
    }
    val basicOptions =
      createBasicCompileOptions(fullClasspath, toolboxPluginOptions)

    s"$basicOptions $compileOptions"
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


  def decodeLabel(targetLabel: String): String = targetLabel.replace(";", ":")

  def encodeLabel(targetLabel: String): String = targetLabel.replace(":", ";")
}