package scala {
  package rulesscala {
    // proxy to private[scala] compiler API
    object Proxy {
      def tokenize(cmd: String): List[String] = sys.process.Parser.tokenize(cmd)
    }
  }
}

package io.bazel.rulesscala.utils {
  trait CompilerAPICompat {
    def tokenize(cmd: String): List[String] = scala.rulesscala.Proxy.tokenize(cmd)
  }
}
