package third_party.dependency_analyzer.src.main.io.bazel.rulesscala.dependencyanalyzer

import scala.tools.nsc.Global

class Reporter(global: Global) {
  def error(pos: global.Position, message: String): Unit = {
    global.reporter.doReport(pos, message, global.reporter.ERROR)
  }

  def warning(pos: global.Position, message: String): Unit = {
    global.reporter.doReport(pos, message, global.reporter.WARNING)
  }
}
