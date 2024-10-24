package io.bazel.rulesscala.utils

import scala.tools.cmd.CommandLineParser

trait CompilerAPICompat {
  def tokenize(cmd: String): List[String] = CommandLineParser.tokenize(cmd)
}
