package io.bazel.rulesscala.scalac;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import scala.tools.nsc.reporters.Reporter;
import scala.tools.nsc.Settings;
import scala.tools.nsc.reporters.ConsoleReporter;
import scala.tools.nsc.MainClass;
import scala.tools.nsc.Global;


public class ReportableMainClass extends MainClass{
    private Global compiler;
    private final CompileOptions ops;

    public ReportableMainClass(CompileOptions ops){
        this.ops = ops;
    }

    @Override
    public Global newCompiler() {
        if (compiler == null) {
            Settings settings = super.settings();
            ConsoleReporter consoleReporter = new ConsoleReporter(settings);
            Reporter[] reporters;
            if (ops.enableDiagnosticsReport) {
                reporters = new Reporter[] { consoleReporter };
            } else {
                Path path = Paths.get(ops.diagnosticsFile);
                try {
                    Files.deleteIfExists(path);
                    Files.createFile(path);
                } catch (IOException e) {
                    throw new RuntimeException("Could not delete/make diagnostics proto file", e);
                }
                reporters = new Reporter[] {
                        consoleReporter,
                        new ProtoReporter(settings),
                };
            }
            compiler = new Global(settings, new CompositeReporter(reporters));
        }
        return compiler;
    }
}

