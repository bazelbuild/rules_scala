package io.bazel.rules_scala.target_split

object BazelGen {
  final case class ScalaLibrary(
    name: String,
    srcs: List[String],
    deps: List[String],
    visibility: List[String],
    exports: List[String]) {

    def render: String = {
      def q(s: String): String = "\"" + s + "\""
      def list(s: List[String], indent: String): String =
        if (s.isEmpty) "[]"
        else s.iterator.map(q).mkString(s"[\n$indent", s",\n$indent",s",\n$indent]")

      val ident = " " * 8
      s"""|scala_library(
          |    name = ${q(name)},
          |    srcs = ${list(srcs, ident)},
          |    deps = ${list(deps, ident)},
          |    visibility = ${list(visibility, ident)},
          |    exports = ${list(exports, ident)},
          |    )""".stripMargin
    }
  }
}

