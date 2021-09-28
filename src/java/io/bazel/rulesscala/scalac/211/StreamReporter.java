package io.bazel.rulesscala.scalac;

import java.io.BufferedReader;
import java.io.ByteArrayInputStream;
import java.io.InputStreamReader;
import java.io.PrintStream;
import java.io.PrintWriter;
import scala.tools.nsc.Settings;
import scala.tools.nsc.reporters.ConsoleReporter;

class StreamReporter extends ConsoleReporter {
  public StreamReporter(Settings settings, PrintStream out, PrintStream err) {
    super(
        settings,
        new BufferedReader(new InputStreamReader(new ByteArrayInputStream(new byte[0]))),
        new PrintWriter(out));
  }

  @Override
  public void reset() {
    super.reset();
  }
}
