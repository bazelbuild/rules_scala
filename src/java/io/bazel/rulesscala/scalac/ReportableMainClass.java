package io.bazel.rulesscala.scalac;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import scala.tools.nsc.Settings;
import scala.tools.nsc.reporters.ConsoleReporter;
import scala.tools.nsc.MainClass;
import scala.tools.nsc.Global;

public class ReportableMainClass extends MainClass {
    private Global compiler;
    private final CompileOptions ops;

    public ReportableMainClass(CompileOptions ops) {
        this.ops = ops;
    }

    @Override
    public Global newCompiler() {
        if (!ops.enableDiagnosticsReport) {
            createDiagnosticsFile();
            return super.newCompiler();
        }

        if (compiler == null) {
            createDiagnosticsFile();

            Settings settings = super.settings();
            ConsoleReporter reporter = new ProtoReporter(settings);

            compiler = new Global(settings, reporter);
        }
        return compiler;
    }

    private void createDiagnosticsFile() {
        Path path = Paths.get(ops.diagnosticsFile);
        try {
            Files.deleteIfExists(path);
            Files.createFile(path);
        } catch (IOException e) {
            throw new RuntimeException("Could not delete/make diagnostics proto file", e);
        }
    }
}
