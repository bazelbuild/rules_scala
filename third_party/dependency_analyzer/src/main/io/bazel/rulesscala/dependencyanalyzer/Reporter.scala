package io.bazel.rulesscala.dependencyanalyzer

import scala.tools.nsc.Global
import io.bazel.rulesscala.scalac.reporter.DepsTrackingReporter
import scala.collection.JavaConverters._

class Reporter(global: Global) {
  def registerAstJars(usedJarPathToPositions: Map[String, Reporter.this.global.Position]): Unit = {
    global.reporter match {
      case r: DepsTrackingReporter => r.registerAstUsedJars(usedJarPathToPositions.keys.toSet.asJava)
      case _ =>
    }
  }

  def error(pos: global.Position, message: String): Unit = {
    global.reporter.error(pos, message)
  }

  def warning(pos: global.Position, message: String): Unit = {
    global.reporter.warning(pos, message)
  }
}
