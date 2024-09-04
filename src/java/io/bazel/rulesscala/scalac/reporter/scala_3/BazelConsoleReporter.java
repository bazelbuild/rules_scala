package io.bazel.rulesscala.scalac.reporter;

import dotty.tools.dotc.core.Contexts;
import dotty.tools.dotc.reporting.AbstractReporter;
import dotty.tools.dotc.reporting.Diagnostic;
import dotty.tools.dotc.reporting.Reporter;
import scala.Console;

import java.io.BufferedReader;
import java.io.PrintWriter;

// Redefinitions of https://github.com/scala/scala3/blob/46683d0fae74c5d46ed8b63331c1dda6efc03179/compiler/src/dotty/tools/dotc/reporting/ConsoleReporter.scala
// required due to https://github.com/scala/scala3/issues/21533
abstract class BazelConsoleReporter extends AbstractReporter {
  protected final BufferedReader reader;
  protected final PrintWriter writer;
  protected final PrintWriter echoer;

  protected BazelConsoleReporter(BufferedReader reader, PrintWriter writer, PrintWriter echoer){
    super();
    this.reader = reader;
    this.writer = writer;
    this.echoer = echoer;
  }
  protected BazelConsoleReporter(){
    this(
      Console.in(),
      new PrintWriter(Console.err(), true),
      new PrintWriter(Console.out(), true)
    );
  }

  public void printMessage(String msg) {
    writer.println(msg);
    writer.flush();
  }
  public void echoMessage(String msg){
    echoer.println(msg);
    echoer.flush();
  }

  @Override
  public void flush(Contexts.Context ctx) {
    writer.flush();
    echoer.flush();
  }

  @Override
  public void doReport(Diagnostic dia, Contexts.Context ctx) {
    if(dia.level() == Diagnostic.INFO) echoMessage(messageAndPos(dia, ctx));
    else printMessage(messageAndPos(dia, ctx));

    if((boolean) ctx.settings().Xprompt().valueIn(ctx.settingsState())){
      boolean displayPrompt = dia instanceof Diagnostic.Error;
      if(dia instanceof  Diagnostic.Warning){
        displayPrompt = (boolean) ctx.settings().XfatalWarnings().valueIn(ctx.settingsState());
      }
      if(displayPrompt) Reporter.displayPrompt(reader, writer);
    }
  }
}
