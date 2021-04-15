package io.bazel.rulesscala.dependencyanalyzer

import scala.tools.nsc.Global

trait UsageType

case object Direct extends UsageType

case object BaseClass extends UsageType

case class Usage(position: Global#Position, usageType: UsageType)