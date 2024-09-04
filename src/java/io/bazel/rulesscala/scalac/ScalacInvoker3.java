package io.bazel.rulesscala.scalac;

import dotty.tools.dotc.Driver;
import io.bazel.rulesscala.scalac.compileoptions.CompileOptions;
import io.bazel.rulesscala.scalac.reporter.ProtoReporter;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;

// Invokes Scala 3 compiler
class ScalacInvoker {
  public static ScalacInvokerResults invokeCompiler(CompileOptions ops, String[] compilerArgs)
      throws IOException, Exception {

    ScalacInvokerResults results = new ScalacInvokerResults();
    Driver driver = new dotty.tools.dotc.Driver();
    ProtoReporter protoReporter = new ProtoReporter();

    results.startTime = System.currentTimeMillis();

    driver.process(compilerArgs, protoReporter, null);

    results.stopTime = System.currentTimeMillis();

    Files.createFile(Paths.get(ops.diagnosticsFile));
    Files.createFile(Paths.get(ops.scalaDepsFile));

    protoReporter.writeTo(Paths.get(ops.diagnosticsFile));

    if (protoReporter.hasErrors()) {
      // reporter.flush();
      throw new RuntimeException("Build failed");
    }

    return results;
  }
}
