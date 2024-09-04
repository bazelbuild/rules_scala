package io.bazel.rulesscala.scalac;

import io.bazel.rulesscala.scalac.compileoptions.CompileOptions;
import java.nio.file.Paths;
import java.nio.file.Files;

import io.bazel.rulesscala.scalac.reporter.DepsTrackingReporter;
import io.bazel.rulesscala.scalac.reporter.ProtoReporter;
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
    Driver driver = new ReportableDriver(ops);

    Tuple2<scala.collection.immutable.List<AbstractFile>, Contexts.Context> r = 
      driver.setup(compilerArgs, driver.initCtx().fresh())
        .getOrElse(() -> {
          throw new ScalacWorker.InvalidSettings();
        });

    Contexts.Context ctx = r._2;
    Compiler compiler = driver.newCompiler(ctx);

    results.startTime= System.currentTimeMillis();
    Reporter reporter = driver.doCompile(compiler, r._1, ctx);
    results.stopTime = System.currentTimeMillis();

    if (reporter instanceof ProtoReporter) {
      ProtoReporter protoReporter = (ProtoReporter) reporter;
      protoReporter.writeTo(Paths.get(ops.diagnosticsFile));
    }

    if (reporter instanceof DepsTrackingReporter) {
      DepsTrackingReporter depTrackingReporter = (DepsTrackingReporter) reporter;
      depTrackingReporter.prepareReport(ctx);
      depTrackingReporter.writeDiagnostics(ops.diagnosticsFile);
    }

    if (reporter.hasErrors()) {
      reporter.flush(ctx);
      throw new ScalacWorker.CompilationFailed("with errors.");
    }

    return results;
  }

}
