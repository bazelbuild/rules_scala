package io.bazel.rulesscala.scalac.reporter;

import dotty.tools.dotc.core.Contexts;
import dotty.tools.dotc.interfaces.SourcePosition;
import dotty.tools.dotc.reporting.Diagnostic;
import dotty.tools.dotc.reporting.Reporter;
import io.bazel.rules_scala.diagnostics.Diagnostics;
import scala.Console;

import java.io.File;
import java.io.IOException;
import java.io.PrintWriter;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardOpenOption;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

public class ProtoReporter extends BazelConsoleReporter {

  private final Map<String, List<Diagnostics.Diagnostic>> builder = new LinkedHashMap<>();

  public ProtoReporter() {
    super();
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
  public void doReport(Diagnostic dia, Contexts.Context ctx) {
    super.doReport(dia, ctx);

    Diagnostics.Diagnostic diagnostic = Diagnostics.Diagnostic.newBuilder()
        .setSeverity(convertSeverity(dia.level()))
        .setMessage(dia.message())
        .setRange(dia.position()
          .map(this::positionToRange)
          .orElse(Diagnostics.Range.getDefaultInstance())
        )
        .build();

    // TODO: Handle generated files
    String uri = "workspace-root://" + dia.position()
      .flatMap((srcPos) -> srcPos.source().jfile()).map(File::toString)
      .orElse("virtual-file");
    List<Diagnostics.Diagnostic> diagnostics = builder.computeIfAbsent(uri, key -> new ArrayList<>());
    diagnostics.add(diagnostic);
  }

  private Diagnostics.Severity convertSeverity(int severity) {
    switch (severity){
      case Diagnostic.ERROR: return Diagnostics.Severity.ERROR;
      case Diagnostic.WARNING: return Diagnostics.Severity.WARNING;
      case Diagnostic.INFO: return Diagnostics.Severity.INFORMATION;
      default: throw new RuntimeException("Unknown severity: "+ severity);
    }
  }

  private Diagnostics.Range positionToRange(SourcePosition pos) {
      return Diagnostics.Range.newBuilder()
        .setStart(
          Diagnostics.Position.newBuilder()
            .setLine(pos.startLine())
            .setCharacter(pos.startColumn())
        )
        .setEnd(
          Diagnostics.Position.newBuilder()
            .setLine(pos.endLine())
            .setCharacter(pos.endColumn())
            .build())
        .build();
  }
}
