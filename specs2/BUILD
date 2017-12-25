load("//scala:scala_import.bzl", "scala_import")

package(default_visibility = ["//visibility:public"])
java_import(
    name = "specs2",
    jars = [
      "@io_bazel_rules_scala_org_specs2_specs2_core//jar:file",
      "@io_bazel_rules_scala_org_specs2_specs2_common//jar:file",
      "@io_bazel_rules_scala_org_specs2_specs2_matcher//jar:file",
      "@io_bazel_rules_scala_org_scalaz_scalaz_effect//jar:file",
      "@io_bazel_rules_scala_org_scalaz_scalaz_core//jar:file",
    ],
    deps = [
      "//external:io_bazel_rules_scala/dependency/scala/scala_xml",
      "//external:io_bazel_rules_scala/dependency/scala/parser_combinators",
      "//external:io_bazel_rules_scala/dependency/scala/scala_library",
      "//external:io_bazel_rules_scala/dependency/scala/scala_reflect"
    ]
)
