package io.bazel.rulesscala.scalac;

import io.bazel.rulesscala.scalac.compileoptions.CompileOptions;
import java.nio.file.Paths;
import java.nio.file.Files;
import scala.Tuple2;
import java.io.IOException;

import dotty.tools.dotc.reporting.Reporter;
import dotty.tools.dotc.Compiler;
import dotty.tools.dotc.Driver;
import dotty.tools.dotc.core.Contexts;
import dotty.tools.io.AbstractFile;

//Invokes Scala 3 compiler
class ScalacInvoker{
  public static ScalacInvokerResults invokeCompiler(CompileOptions ops, String[] compilerArgs)
    throws IOException, Exception{


    ScalacInvokerResults results = new ScalacInvokerResults();
    Driver driver = new dotty.tools.dotc.Driver();
    Contexts.Context ctx = driver.initCtx().fresh();

    Tuple2<scala.collection.immutable.List<AbstractFile>, Contexts.Context> r = 
      driver.setup(compilerArgs, ctx)
        .getOrElse(() -> {
          throw new ScalacWorker.InvalidSettings();
        });

    Compiler compiler = driver.newCompiler(r._2);

    results.startTime= System.currentTimeMillis();

    Reporter reporter = driver.doCompile(compiler, r._1, r._2);

    results.stopTime = System.currentTimeMillis();

    Files.createFile(
        Paths.get(ops.diagnosticsFile));
    Files.createFile(
        Paths.get(ops.scalaDepsFile));


    if (reporter.hasErrors()) {
//      reporter.flush();
      throw new ScalacWorker.CompilationFailed("with errors.");
    }

    return results;
  }
}
