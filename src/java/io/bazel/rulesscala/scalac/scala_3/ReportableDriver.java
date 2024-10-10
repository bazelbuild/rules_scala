package io.bazel.rulesscala.scalac;

import dotty.tools.dotc.Driver;
import dotty.tools.dotc.core.Contexts;
import dotty.tools.io.AbstractFile;
import io.bazel.rulesscala.scalac.compileoptions.CompileOptions;
import io.bazel.rulesscala.scalac.reporter.DepsTrackingReporter;
import io.bazel.rulesscala.scalac.reporter.ProtoReporter;
import scala.Option;
import scala.Tuple2;
import scala.collection.immutable.List;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

public class ReportableDriver extends Driver {
    private final CompileOptions ops;

    public ReportableDriver(CompileOptions ops) {
        this.ops = ops;
    }

  @Override
  public Option<Tuple2<List<AbstractFile>, Contexts.Context>> setup(String[] args, Contexts.Context rootCtx) {
    Contexts.FreshContext ictx = rootCtx.fresh();

    createFreshFile(ops.diagnosticsFile, "diagnostics proto file");
    if(ops.enableDiagnosticsReport){
      ictx.setReporter(new ProtoReporter());
    }

    createFreshFile(ops.scalaDepsFile, "Scala dependencies proto file");
    ictx.setReporter(new DepsTrackingReporter(ops, ictx.reporter()));

    return super.setup(args, ictx);
  }

  private void createFreshFile(String pathString, String context){
    Path path = Paths.get(pathString);
    try {
      Files.deleteIfExists(path);
      Files.createFile(path);
    } catch (IOException e) {
      throw new RuntimeException("Could not delete/make " + context, e);
    }
  }
}
