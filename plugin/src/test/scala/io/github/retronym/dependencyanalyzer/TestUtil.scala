package plugin.src.test.scala.io.github.retronym.dependencyanalyzer

import java.io.File

import coursier.maven.MavenRepository
import coursier.{Cache, Dependency, Fetch, Resolution}

import scala.reflect.internal.util.{BatchSourceFile, NoPosition}
import scala.reflect.io.VirtualDirectory
import scala.tools.cmd.CommandLineParser
import scala.tools.nsc.reporters.StoreReporter
import scala.tools.nsc.{CompilerCommand, Global, Settings}
import scalaz.concurrent.Task

object TestUtil {

  import scala.language.postfixOps

  def run(code: String, withDirect: Seq[String] = Seq.empty, withIndirect: Map[String, String] = Map.empty): Seq[String] = {
    val compileOptions = Seq(
      constructParam("direct-jars", withDirect),
      constructParam("indirect-jars", withIndirect.keys),
      constructParam("indirect-targets", withIndirect.values)
    ).mkString(" ")

    val extraClasspath = withDirect ++ withIndirect.keys

    val reporter: StoreReporter = runCompilation(code, compileOptions, extraClasspath)
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

    println("basicOptions: " + basicOptions)

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

  def getResourceContent(resourceName: String): String = {
    println("getResourceContent "+ resourceName)
    val resource = getClass.getClassLoader.getResourceAsStream(resourceName)
    println("getResourceContent resource: "+ resource)

    val file = scala.io.Source.fromInputStream(resource)
    file.getLines.mkString
  }

  lazy val toolboxClasspath: String = getResourceContent("toolbox.classpath")
  lazy val toolboxPluginOptions: String = getResourceContent("toolbox.plugin")

  private def createBasicCompileOptions(classpath: String, usePluginOptions: String) =
    s"-classpath $classpath $usePluginOptions"

  private def constructParam(name: String, values: Iterable[String]) = {
    if (values.isEmpty) ""
    else s"-P:dependency-analyzer:$name:${values.mkString(":")}"
  }

  object Coursier {
    private final val repositories = Seq(
      Cache.ivy2Local,
      MavenRepository("https://repo1.maven.org/maven2")
    )

    def getArtifact(dependency: Dependency) = getArtifacts(Seq(dependency)).head

    private def getArtifacts(deps: Seq[Dependency]): Seq[String] =
      getArtifacts(deps, toAbsolutePath)

    private def getArtifacts(deps: Seq[Dependency], fileToString: File => String): Seq[String] = {
      val toResolve = Resolution(deps.toSet)
      val fetch = Fetch.from(repositories, Cache.fetch())
      val resolution = toResolve.process.run(fetch).run
      val resolutionErrors = resolution.errors
      if (resolutionErrors.nonEmpty)
        sys.error(s"Modules could not be resolved:\n$resolutionErrors.")
      val errorsOrJars = Task
        .gatherUnordered(resolution.artifacts.map(Cache.file(_).run))
        .unsafePerformSync
      val onlyErrors = errorsOrJars.filter(_.isLeft)
      if (onlyErrors.nonEmpty)
        sys.error(s"Jars could not be fetched from cache:\n$onlyErrors")
      errorsOrJars.flatMap(_.map(fileToString).toList)
    }

    private def toAbsolutePath(f: File): String =
      f.getAbsolutePath

  }

}
