package io.bazel.rulesscala.scalac;

import io.bazel.rulesscala.scalac.compileoptions.CompileOptions;
import io.bazel.rulesscala.scalac.reporter.DepsTrackingReporter;
import io.bazel.rulesscala.scalac.reporter.ProtoReporter;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import scala.tools.nsc.Global;
import scala.tools.nsc.MainClass;
import scala.tools.nsc.Settings;
import scala.tools.nsc.reporters.Reporter;
import java.lang.AutoCloseable;

public class ReportableMainClass extends MainClass {
  private Reporter reporter;
  private final CompileOptions ops;
  private Global compiler = null;

  public ReportableMainClass(CompileOptions ops) {
    this.ops = ops;
  }

  public void close() throws Exception{
    if(compiler != null){

      //nsc.Global didn't inherit from Closeable until 2.12.9.
      if(compiler instanceof AutoCloseable){
        ((AutoCloseable)compiler).close();
      }
      compiler = null;
    }
  }

  @Override
  public Global newCompiler() {
    createDiagnosticsFile();
    createScalaDepsFile();
    Settings settings = super.settings();
    if (ops.enableDiagnosticsReport) {
      reporter = new ProtoReporter(settings);
    }

    reporter = new DepsTrackingReporter(settings, ops, reporter);

    compiler = new Global(settings, reporter);
    return compiler;
  }

  private void createDiagnosticsFile() {
    Path path = Paths.get(ops.diagnosticsFile);
    try {
      Files.deleteIfExists(path);
      Files.createFile(path);
    } catch (IOException e) {
      throw new RuntimeException("Could not delete/make diagnostics proto file", e);
    }
  }

  private void createScalaDepsFile() {
    Path path = Paths.get(ops.scalaDepsFile);
    try {
      Files.deleteIfExists(path);
      Files.createFile(path);
    } catch (IOException e) {
      throw new RuntimeException("Could not delete/make sdeps proto file", e);
    }
  }

  public Reporter getReporter() {
    return this.reporter;
  }
}
