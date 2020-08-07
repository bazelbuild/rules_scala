package io.bazel.rulesscala.scalac;

import io.bazel.rules_scala.diagnostics.Diagnostics;
import scala.reflect.internal.util.Position;
import scala.reflect.internal.util.RangePosition;
import scala.tools.nsc.Settings;
import scala.tools.nsc.reporters.ConsoleReporter;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardOpenOption;
import java.util.*;

public class ProtoReporter extends ConsoleReporter {

  private final Settings settings;
  private final Map<String, List<Diagnostics.Diagnostic>> builder;
  private final Map<Position, Severity> positions = new HashMap<>();
  private final Map<Position, List<String>> messages = new HashMap<>();


  private final boolean isVerbose;
  private final boolean noWarnings;
  private final boolean isPromptSet;
  private final boolean isDebug;

  public ProtoReporter(Settings settings) {
    super(settings);
    this.settings = settings;
    this.isVerbose = (boolean) settings.verbose().value();
    this.noWarnings = settings.nowarnings().value();
    this.isPromptSet = settings.prompt().value();
    this.isDebug = settings.debug().value();
    builder = new LinkedHashMap<>();
  }

  @Override
  public void reset() {
    super.reset();
    positions.clear();
    messages.clear();
  }

  public void writeTo(Path path) throws IOException {
    Diagnostics.TargetDiagnostics.Builder targetDiagnostics = Diagnostics.TargetDiagnostics.newBuilder();
    for (Map.Entry<String, List<Diagnostics.Diagnostic>> entry : builder.entrySet()) {
      targetDiagnostics.addDiagnostics(Diagnostics.FileDiagnostics.newBuilder().setPath(entry.getKey()).addAllDiagnostics(entry.getValue()));
    }
    Files.write(path, targetDiagnostics.build().toByteArray(), StandardOpenOption.CREATE, StandardOpenOption.APPEND);
  }

  @Override
  public void info0(Position pos, String msg, Object severity, boolean force) {
    Severity actualSeverity = (Severity) severity;
    if(severity.equals(INFO())){
      if(isVerbose || force){
        actualSeverity.count_$eq(actualSeverity.count());
        display(pos, msg, actualSeverity);
      }
    } else {
        boolean hidden = testAndLog(pos, actualSeverity, msg);
        if (!severity.equals(WARNING()) || !noWarnings) {
            if(!hidden || isPromptSet){
                actualSeverity.count_$eq(actualSeverity.count() + 1);
                display(pos, msg, actualSeverity);
            }
            else if(isDebug){
                actualSeverity.count_$eq(actualSeverity.count() + 1);
                display(pos, "[ suppressed ] " + msg, actualSeverity);
            }

            if(isPromptSet)
                displayPrompt();
    }
  }

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

  private boolean testAndLog(Position pos, Severity severity, String msg) {
    Position fpos = pos.focus();
    Severity focusSeverity = positions.getOrDefault(fpos, (Severity) INFO());
    boolean supress = false;
    if(focusSeverity.equals(ERROR()))
      supress = true;

    if(focusSeverity.id() > severity.id())
      supress = true;

    if(severity.equals(focusSeverity) && messages.computeIfAbsent(fpos,(key) -> new ArrayList<>()).contains(msg))
      supress = true;

    positions.put(fpos, severity);
    messages.computeIfAbsent(fpos, (key) -> new ArrayList<>()).add(msg);
    return supress;
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
}
