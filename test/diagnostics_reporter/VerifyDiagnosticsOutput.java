package diagnostics_reporter;

import io.bazel.rules_scala.diagnostics.Diagnostics;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.Arrays;
import java.util.List;
import java.util.NoSuchElementException;
import java.util.stream.Collectors;

class VerifyDiagnosticsOutput {
  private final Diagnostics.Severity severity;
  private final String message;

  VerifyDiagnosticsOutput(
      Diagnostics.Severity severity, String message) {
    this.severity = severity;
    this.message = message;
  }

  public static List<Diagnostics.Diagnostic> getDiagnostics(String path) throws IOException {
    return Diagnostics.TargetDiagnostics.parseFrom(Files.readAllBytes(Paths.get(path)))
        .getDiagnosticsList()
        .stream()
        .flatMap(diagnosticList -> diagnosticList.getDiagnosticsList().stream())
        .collect(Collectors.toList());
  }

  public void testOutput(List<Diagnostics.Diagnostic> diagnostics) throws NoSuchElementException {
    if (diagnostics.stream()
        .noneMatch(
            diagnosticInfo ->
                diagnosticInfo.getMessage().equalsIgnoreCase(message)
                    && diagnosticInfo.getSeverity().equals(severity)))
      throw new NoSuchElementException(
          "No diagnostics with severity: "
              + severity
              + " and message: "
              + message
              + ", found amongst diagnostics: "
              + Arrays.toString(diagnostics.toArray()));
  }
}
