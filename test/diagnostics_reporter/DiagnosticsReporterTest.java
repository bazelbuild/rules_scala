package diagnostics_reporter;

import io.bazel.rules_scala.diagnostics.Diagnostics;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class DiagnosticsReporterTest {
   public static void main(String[] args) throws IOException {
    if (args.length != 1) throw new IllegalArgumentException("Args: <diagnostics_output>");

    String diagnosticsOutput = args[0];
    for (Map.Entry<String, VerifyDiagnosticsOutput[]> entry : DiagnosticsReporterTestCases.tests.entrySet()) {
      String test = entry.getKey();
      VerifyDiagnosticsOutput[] expectedDiagnosticsOutputs = entry.getValue();
      System.out.println("Test case: " + test);
      List<Diagnostics.Diagnostic> diagnostics =
          VerifyDiagnosticsOutput.getDiagnostics(
              diagnosticsOutput + "/" + test + ".diagnosticsproto");
      for (VerifyDiagnosticsOutput expectedDiagnostic : expectedDiagnosticsOutputs) {
        expectedDiagnostic.testOutput(diagnostics);
      }
    }
  }
}
