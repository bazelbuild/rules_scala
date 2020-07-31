package diagnostics_reporter;

import io.bazel.rules_scala.diagnostics.Diagnostics;

import java.io.IOException;
import java.util.List;
import java.util.Map;

public class DiagnosticsReporterTest {
    private static final Map<String, VerifyDiagnosticsOutput[]> tests = Map.of(
            "error_file", new VerifyDiagnosticsOutput[]{new VerifyDiagnosticsOutput(Diagnostics.Severity.ERROR, 5, 2, 6, 0)},
            "two_errors_file", new VerifyDiagnosticsOutput[]{new VerifyDiagnosticsOutput(Diagnostics.Severity.ERROR, 4, 4, 5, 0), new VerifyDiagnosticsOutput(Diagnostics.Severity.ERROR, 5, 4, 6, 0)},
            "warning_file", new VerifyDiagnosticsOutput[]{new VerifyDiagnosticsOutput(Diagnostics.Severity.WARNING, 0, 0, 0, 7)},
            "error_and_warning_file", new VerifyDiagnosticsOutput[]{new VerifyDiagnosticsOutput(Diagnostics.Severity.WARNING, 0, 0, 0, 7), new VerifyDiagnosticsOutput(Diagnostics.Severity.ERROR, 4, 4, 5, 0)},
            "info_file", new VerifyDiagnosticsOutput[]{new VerifyDiagnosticsOutput(Diagnostics.Severity.INFORMATION, -1, -1, 0, 0)}
            );

    public static void main(String[] args) throws IOException {
        if(args.length != 1)
            throw new IllegalArgumentException("Args: <diagnostics_output>");

        String diagnosticsOutput = args[0];
        for (Map.Entry<String, VerifyDiagnosticsOutput[]> entry : tests.entrySet()) {
            String test = entry.getKey();
            VerifyDiagnosticsOutput[] expectedDiagnosticsOutputs = entry.getValue();
            List<Diagnostics.Diagnostic> diagnostics = VerifyDiagnosticsOutput.getDiagnostics(diagnosticsOutput + "/" + test + ".diagnosticsproto");
            for (VerifyDiagnosticsOutput expectedDiagnostic : expectedDiagnosticsOutputs) {
                expectedDiagnostic.testOutput(diagnostics);
            }
        }

    }
}