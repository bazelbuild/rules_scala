package io.bazel.rulesscala.utils

import scala.tools.cmd.CommandLineParser

object CommandLineParserAdapter {
  def tokenize(cmd: String): List[String] = CommandLineParser.tokenize(cmd)
}
