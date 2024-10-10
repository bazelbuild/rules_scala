package diagnostics_reporter;

import io.bazel.rules_scala.diagnostics.Diagnostics;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

class DiagnosticsReporterTestCases {
  @SuppressWarnings("DoubleBraceInitialization")
  static final Map<String, diagnostics_reporter.VerifyDiagnosticsOutput[]> tests =
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
}
