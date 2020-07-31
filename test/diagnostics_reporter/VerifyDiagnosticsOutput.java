package diagnostics_reporter;

import io.bazel.rules_scala.diagnostics.Diagnostics;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Arrays;
import java.util.List;
import java.util.NoSuchElementException;
import java.util.stream.Collectors;

class VerifyDiagnosticsOutput {
    public static void main(String[] args) throws IOException {
        String[] diagnosticsArgs = args[1].split(" ");
        if(args.length != 2 || diagnosticsArgs.length % 5 != 0)
            throw new IllegalArgumentException("Args: <path_to_diagnostics> [severity start_line start_char end_line end_char], you passed " + Arrays.toString(args));
        String path = args[0];
        List<Diagnostics.Diagnostic> diagnostics =
                Diagnostics.TargetDiagnostics.parseFrom(Files.readAllBytes(Path.of(path)))
                        .getDiagnosticsList().stream().flatMap(diagnosticList -> diagnosticList.getDiagnosticsList().stream()).collect(Collectors.toList());
        for(int i = 0; i < args.length; i+=5){
            Diagnostics.Severity severity;
            switch (Integer.parseInt(diagnosticsArgs[i])){
                case 0:
                    severity = Diagnostics.Severity.UNKNOWN;
                    break;
                case 1:
                    severity = Diagnostics.Severity.ERROR;
                    break;
                case 2:
                    severity = Diagnostics.Severity.WARNING;
                    break;
                case 3:
                    severity = Diagnostics.Severity.INFORMATION;
                    break;
                case 4:
                    severity = Diagnostics.Severity.HINT;
                    break;
                default:
                    throw new IllegalArgumentException("Severity must be a number between 0 and 4!");
            }

            int startLine = Integer.parseInt(diagnosticsArgs[1]);
            int startChar = Integer.parseInt(diagnosticsArgs[2]);
            int endLine = Integer.parseInt(diagnosticsArgs[3]);
            int endChar = Integer.parseInt(diagnosticsArgs[4]);
            Diagnostics.Severity finalSeverity = severity;
            if(diagnostics.stream().noneMatch(diagnosticInfo ->
                    diagnosticInfo.getRange().getStart().getLine() == startLine &&
                            diagnosticInfo.getRange().getStart().getCharacter() == startChar &&
                            diagnosticInfo.getRange().getEnd().getLine() == endLine &&
                            diagnosticInfo.getRange().getEnd().getCharacter() == endChar &&
                            diagnosticInfo.getSeverity().equals(finalSeverity)))
                throw new NoSuchElementException("No diagnostics with severity" + severity + ", starting line" + startLine
                        + "and character" + startChar + ", ending line " + endLine + " and character " + endChar);
        }

    }
}
