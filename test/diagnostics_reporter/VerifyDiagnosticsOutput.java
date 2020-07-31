package diagnostics_reporter;

import io.bazel.rules_scala.diagnostics.Diagnostics;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Arrays;
import java.util.NoSuchElementException;
import java.util.stream.Collectors;
import java.util.List;

class VerifyDiagnosticsOutput {
    private final Diagnostics.Severity severity;
    private final int startLine;
    private final int startChar;
    private final int endLine;
    private final int endChar;

    VerifyDiagnosticsOutput(Diagnostics.Severity severity, int startLine, int startChar, int endLine, int endChar) {
        this.severity = severity;
        this.startLine = startLine;
        this.startChar = startChar;
        this.endLine = endLine;
        this.endChar = endChar;
    }

    public static List<Diagnostics.Diagnostic> getDiagnostics(String path) throws IOException {
        return Diagnostics.TargetDiagnostics.parseFrom(Files.readAllBytes(Path.of(path)))
                .getDiagnosticsList().stream().flatMap(diagnosticList -> diagnosticList.getDiagnosticsList().stream()).collect(Collectors.toList());
    }

    public void testOutput(List<Diagnostics.Diagnostic> diagnostics) throws NoSuchElementException {
        if (diagnostics.stream().noneMatch(diagnosticInfo ->
                diagnosticInfo.getRange().getStart().getLine() == startLine &&
                        diagnosticInfo.getRange().getStart().getCharacter() == startChar &&
                        diagnosticInfo.getRange().getEnd().getLine() == endLine &&
                        diagnosticInfo.getRange().getEnd().getCharacter() == endChar &&
                        diagnosticInfo.getSeverity().equals(severity)))
            throw new NoSuchElementException("No diagnostics with severity" + severity + ", starting line" + startLine
                    + " and character" + startChar + ", ending line " + endLine + " and character " + endChar + ", diagnostics found for the target: "
                    + Arrays.toString(diagnostics.toArray()));
    }
}
