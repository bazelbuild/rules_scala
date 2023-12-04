package diagnostics_reporter;

import io.bazel.rules_scala.diagnostics.Diagnostics;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class DiagnosticsReporterTest {
  @SuppressWarnings("DoubleBraceInitialization")
  private static final Map<String, diagnostics_reporter.VerifyDiagnosticsOutput[]> tests =
      new HashMap<String, diagnostics_reporter.VerifyDiagnosticsOutput[]>() {
        {
          put(
              "error_file",
              new diagnostics_reporter.VerifyDiagnosticsOutput[] {
                new diagnostics_reporter.VerifyDiagnosticsOutput(
                    Diagnostics.Severity.ERROR, "\')\' expected but \'}\' found.")
              });
          put(
              "two_errors_file",
              new diagnostics_reporter.VerifyDiagnosticsOutput[] {
                new diagnostics_reporter.VerifyDiagnosticsOutput(
                    Diagnostics.Severity.ERROR, "not found: value printn"),
                new diagnostics_reporter.VerifyDiagnosticsOutput(
                    Diagnostics.Severity.ERROR, "not found: value prinf")
              });
          put(
              "warning_file",
              new diagnostics_reporter.VerifyDiagnosticsOutput[] {
                new diagnostics_reporter.VerifyDiagnosticsOutput(
                    Diagnostics.Severity.WARNING, "Unused import")
              });
          put(
              "error_and_warning_file",
              new diagnostics_reporter.VerifyDiagnosticsOutput[] {
                new diagnostics_reporter.VerifyDiagnosticsOutput(
                    Diagnostics.Severity.WARNING, "Unused import"),
                new diagnostics_reporter.VerifyDiagnosticsOutput(
                    Diagnostics.Severity.ERROR, "not found: value printn")
              });
          put(
              "info_file",
              new diagnostics_reporter.VerifyDiagnosticsOutput[] {
                new diagnostics_reporter.VerifyDiagnosticsOutput(
                    Diagnostics.Severity.INFORMATION, "[running phase parser on InfoFile.scala]")
              });
        }
      };

  public static void main(String[] args) throws IOException {
    if (args.length != 1) throw new IllegalArgumentException("Args: <diagnostics_output>");

    String diagnosticsOutput = args[0];
    for (Map.Entry<String, VerifyDiagnosticsOutput[]> entry : tests.entrySet()) {
      String test = entry.getKey();
      VerifyDiagnosticsOutput[] expectedDiagnosticsOutputs = entry.getValue();
      List<Diagnostics.Diagnostic> diagnostics =
          VerifyDiagnosticsOutput.getDiagnostics(
              diagnosticsOutput + "/" + test + ".diagnosticsproto");
      for (VerifyDiagnosticsOutput expectedDiagnostic : expectedDiagnosticsOutputs) {
        expectedDiagnostic.testOutput(diagnostics);
      }
    }
  }
}
