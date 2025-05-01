package io.bazel.rulesscala.utils

import java.nio.file.Path
import java.nio.file.Paths
import scala.reflect.internal.util.BatchSourceFile
import scala.reflect.internal.util.Position
import scala.reflect.io.AbstractFile
import scala.reflect.io.Directory
import scala.reflect.io.PlainDirectory
import scala.reflect.io.VirtualDirectory
import scala.tools.nsc.CompilerCommand
import scala.tools.nsc.Global
import scala.tools.nsc.Settings
import scala.tools.nsc.reporters.StoreReporter
import io.bazel.rulesscala.dependencyanalyzer.DependencyTrackingMethod

object TestUtil extends TestUtilCommon {

  override def runCompiler(
    code: String,
    extraClasspath: List[String] = List.empty,
    dependencyAnalyzerParamsOpt: Option[DependencyAnalyzerTestParams] = None,
    outputPathOpt: Option[Path] = None
  ): List[Diagnostic] = {
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

  class CompatSourcePosition(underlying: Position) extends SourcePosition {
    override def isDefined = underlying.isDefined
    override def line = underlying.line
    override def column = underlying.column
  }
  private def eval(
    code: String,
    compileOptions: String,
    output: AbstractFile
  ): List[Diagnostic] = {
    // TODO: Optimize and cache global.
    val options = CommandLineParserAdapter.tokenize(compileOptions)
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
    .map{ v => 
      new Diagnostic.Error(v.msg, new CompatSourcePosition(v.pos))
    }
  }

  override lazy val builtinClasspaths: Seq[String] =
    Vector(
      pathOf("scala.library.location"),
      pathOf("scala.reflect.location")
    )
}
