package io.bazel.rulesscala.scalac.reporter;

import io.bazel.rules_scala.diagnostics.Diagnostics;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardOpenOption;
import java.util.*;
import scala.collection.immutable.List$;
import scala.reflect.internal.util.CodeAction;
import scala.reflect.internal.util.Position;
import scala.reflect.internal.util.RangePosition;
import scala.tools.nsc.Settings;
import scala.tools.nsc.reporters.ConsoleReporter;

public class ProtoReporter extends ConsoleReporter {

  private final Map<String, List<Diagnostics.Diagnostic>> builder;

  public ProtoReporter(Settings settings) {
    super(settings);
    builder = new LinkedHashMap<>();
  }

  @Override
  public void reset() {
    super.reset();
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
  public void doReport(Position pos, String msg, Severity severity, scala.collection.immutable.List<CodeAction> actions) {
    super.doReport(pos, msg, severity, List$.MODULE$.<CodeAction>empty());

    Diagnostics.Diagnostic diagnostic =
        Diagnostics.Diagnostic.newBuilder()
            .setRange(positionToRange(pos))
            .setSeverity(convertSeverity(severity))
            .setMessage(msg)
            .build();
    // TODO: Handle generated files
    String uri = "workspace-root://" + pos.source().file().path();
    List<Diagnostics.Diagnostic> diagnostics = builder.computeIfAbsent(uri, key -> new ArrayList());
    diagnostics.add(diagnostic);
  }

  private Diagnostics.Severity convertSeverity(Object severity) {
    String stringified = severity.toString().toLowerCase();
    if ("error".equals(stringified)) {
      return Diagnostics.Severity.ERROR;
    } else if ("warning".equals(stringified)) {
      return Diagnostics.Severity.WARNING;
    } else if ("info".equals(stringified)) {
      return Diagnostics.Severity.INFORMATION;
    }
    throw new RuntimeException("Unknown severity: " + stringified);
  }

  private Diagnostics.Range positionToRange(Position pos) {
    if (pos instanceof RangePosition) {
      RangePosition rangePos = (RangePosition) pos;
      int startLine = pos.source().offsetToLine(rangePos.start());
      int endLine = pos.source().offsetToLine(rangePos.end());
      return Diagnostics.Range.newBuilder()
          .setStart(
              Diagnostics.Position.newBuilder()
                  .setLine(startLine)
                  .setCharacter(rangePos.start() - pos.source().lineToOffset(startLine)))
          .setEnd(
              Diagnostics.Position.newBuilder()
                  .setLine(endLine)
                  .setCharacter(rangePos.end() - pos.source().lineToOffset(endLine))
                  .build())
          .build();
    }
    return Diagnostics.Range.newBuilder()
        .setStart(
            Diagnostics.Position.newBuilder()
                .setLine(pos.line() - 1)
                .setCharacter(pos.column() - 1))
        .setEnd(Diagnostics.Position.newBuilder().setLine(pos.line()))
        .build();
  }
}
