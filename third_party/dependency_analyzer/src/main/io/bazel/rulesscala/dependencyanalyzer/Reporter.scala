package io.bazel.rulesscala.dependencyanalyzer

import scala.tools.nsc.Global

class Reporter(global: Global) {
  def error(pos: global.Position, message: String): Unit = {
    global.reporter.error(pos, message)
  }

  def warning(pos: global.Position, message: String): Unit = {
    global.reporter.warning(pos, message)
  }
}
