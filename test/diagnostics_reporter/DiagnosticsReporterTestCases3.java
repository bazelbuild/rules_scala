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
                    Diagnostics.Severity.ERROR, "\')\' expected, but \'}\' found")
              });
          put(
              "two_errors_file",
              new diagnostics_reporter.VerifyDiagnosticsOutput[] {
                new diagnostics_reporter.VerifyDiagnosticsOutput(
                    Diagnostics.Severity.ERROR, "Not found: printn"),
                new diagnostics_reporter.VerifyDiagnosticsOutput(
                    Diagnostics.Severity.ERROR, "Not found: prinf")
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
                // Scala 3 does not report unused import when errors are present
                new diagnostics_reporter.VerifyDiagnosticsOutput(
                  Diagnostics.Severity.ERROR, "Not found: printn")
              });
          put(
              "info_file",
              new diagnostics_reporter.VerifyDiagnosticsOutput[] {
                new diagnostics_reporter.VerifyDiagnosticsOutput(
                    Diagnostics.Severity.INFORMATION, "[log genBCode] Adding static forwarder for \'method main\' from InfoFile to \'module class InfoFile$\'")
              });
        }
      };
}
