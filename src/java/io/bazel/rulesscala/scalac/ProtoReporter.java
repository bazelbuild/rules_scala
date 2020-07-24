package io.bazel.rulesscala.scalac;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardOpenOption;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import scala.reflect.internal.util.Position;
import scala.reflect.internal.util.RangePosition;
import scala.tools.nsc.Settings;
import scala.tools.nsc.reporters.AbstractReporter;

import com.google.devtools.build.lib.diagnostics.Diagnostics;

public class ProtoReporter extends AbstractReporter {

  private final Settings settings;
  Map<String, List<Diagnostics.Diagnostic>> builder;

  public ProtoReporter(Settings settings) {
    this.settings = settings;
    builder = new LinkedHashMap<>();
  }

  public void writeTo(Path path) throws IOException {
    Diagnostics.TargetDiagnostics.Builder targetDiagnostics = Diagnostics.TargetDiagnostics.newBuilder();
    for (Map.Entry<String, List<Diagnostics.Diagnostic>> entry : builder.entrySet()) {
      targetDiagnostics.addDiagnostics(Diagnostics.FileDiagnostics.newBuilder().setPath(entry.getKey()).addAllDiagnostics(entry.getValue()));
    }
    Files.write(path, targetDiagnostics.build().toByteArray(), StandardOpenOption.CREATE, StandardOpenOption.APPEND);
  }

  @Override
  public Settings settings() {
    return settings;
  }

  @Override
  public void display(Position pos, String msg, Severity severity) {
  }

  @Override
  public void displayPrompt() {
  }

  @Override
  public void info0(Position pos, String msg, Object severity, boolean force) {
      Diagnostics.Diagnostic diagnostic = Diagnostics.Diagnostic
          .newBuilder()
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
      return Diagnostics.Range
          .newBuilder()
          .setStart(Diagnostics.Position.newBuilder()
              .setLine(startLine)
              .setCharacter(rangePos.start() - pos.source().lineToOffset(startLine))
          )
          .setEnd(Diagnostics.Position.newBuilder()
              .setLine(endLine)
              .setCharacter(rangePos.end() - pos.source().lineToOffset(endLine))
              .build())
          .build();
    }
    return Diagnostics.Range
            .newBuilder()
            .setStart(Diagnostics.Position.newBuilder().setLine(pos.line() - 1).setCharacter(pos.column() - 1))
            .setEnd(Diagnostics.Position.newBuilder().setLine(pos.line()))
            .build();
  }

  @Override
  public int count(Object severity) {
    return 0;
  }

  @Override
  public void resetCount(Object severity) {
  }
}
