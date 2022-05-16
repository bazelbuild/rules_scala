package io.bazel.rulesscala.dependencyanalyzer

import dotty.tools.dotc.core.Contexts.Context
import dotty.tools.dotc.reporting.Diagnostic.{Error, Warning}
import dotty.tools.dotc.reporting._
import dotty.tools.dotc.util.SourcePosition

object Reporter{
  def error(pos: SourcePosition, message: String)(implicit ctx: Context) : Unit = {
    ctx.reporter.doReport(new Error(NoExplanation(message), pos))
  }

  def warning(pos: SourcePosition, message: String)(implicit ctx: Context) : Unit = {
    ctx.reporter.doReport(new Warning(NoExplanation(message), pos))
  }
}
