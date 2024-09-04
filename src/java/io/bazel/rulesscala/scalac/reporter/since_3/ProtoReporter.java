package io.bazel.rulesscala.scalac.reporter;

import dotty.tools.dotc.core.Contexts.Context;
import dotty.tools.dotc.interfaces.SourcePosition;
import dotty.tools.dotc.reporting.AbstractReporter;
import dotty.tools.dotc.reporting.ConsoleReporter;
import dotty.tools.dotc.reporting.Diagnostic;
import dotty.tools.dotc.reporting.Reporter;
import io.bazel.rules_scala.diagnostics.Diagnostics;
import java.io.IOException;
import java.io.PrintWriter;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardOpenOption;
import java.util.*;

public class ProtoReporter extends AbstractReporter {

  private final Map<String, List<Diagnostics.Diagnostic>> builder;
  private final Reporter delegate;

  public ProtoReporter() {
    super();

    scala.Console$ console = scala.Console$.MODULE$;
    this.delegate = new ConsoleReporter(console.in(), new PrintWriter(console.err(), true));
    builder = new LinkedHashMap<>();
  }

  public void writeTo(Path path) throws IOException {
    Diagnostics.TargetDiagnostics.Builder targetDiagnostics =
        Diagnostics.TargetDiagnostics.newBuilder();
    for (Map.Entry<String, List<Diagnostics.Diagnostic>> entry : builder.entrySet()) {
      targetDiagnostics.addDiagnostics(
          Diagnostics.FileDiagnostics.newBuilder()
              .setPath(entry.getKey())
              .addAllDiagnostics(entry.getValue()));
    }
    Files.write(
        path,
        targetDiagnostics.build().toByteArray(),
        StandardOpenOption.CREATE,
        StandardOpenOption.APPEND);
  }

  @Override
  public void printSummary(Context ctx) {
    delegate.printSummary(ctx);
  }

  @Override
  public void doReport(Diagnostic diag, Context ctx) {
    delegate.doReport(diag, ctx);
    if (diag.position().isEmpty()) {
      return;
    }
    SourcePosition pos = diag.position().get();
    Diagnostics.Diagnostic diagnostic =
        Diagnostics.Diagnostic.newBuilder()
            .setSeverity(convertSeverity(diag.level()))
            .setMessage(diag.message())
            .setRange(positionToRange(pos))
            .build();

    String uri = "workspace-root://" + pos.source().path();
    List<Diagnostics.Diagnostic> diagnostics = builder.computeIfAbsent(uri, key -> new ArrayList());
    diagnostics.add(diagnostic);
  }

  private Diagnostics.Severity convertSeverity(int severity) {
    if (severity == Diagnostic.ERROR) {
      return Diagnostics.Severity.ERROR;
    } else if (severity == Diagnostic.WARNING) {
      return Diagnostics.Severity.WARNING;
    } else if (severity == Diagnostic.INFO) {
      return Diagnostics.Severity.INFORMATION;
    }
    throw new RuntimeException("Unknown severity: " + severity);
  }

  private Diagnostics.Range positionToRange(SourcePosition pos) {
    return Diagnostics.Range.newBuilder()
        .setStart(
            Diagnostics.Position.newBuilder()
                .setLine(pos.startLine())
                .setCharacter(pos.startColumn()))
        .setEnd(
            Diagnostics.Position.newBuilder()
                .setLine(pos.endLine())
                .setCharacter(pos.endColumn())
                .build())
        .build();
  }
}
