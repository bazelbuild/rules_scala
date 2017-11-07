load("//scala:scala.bzl", "scala_library")
load("//specs2:specs2_junit.bzl", "specs2_junit_dependencies")

scala_library(
    name = "specs2_test_discovery",
    srcs = [
        "Specs2RunnerBuilder.scala",
    ],
    visibility = ["//visibility:public"],
    deps = ["//src/java/io/bazel/rulesscala/test_discovery:test_discovery",
            "//external:io_bazel_rules_scala/dependency/junit/junit",
            "//external:io_bazel_rules_scala/dependency/specs2/specs2_core",
            "//external:io_bazel_rules_scala/dependency/specs2/specs2_common",
            "//external:io_bazel_rules_scala/dependency/specs2/specs2_matcher",
            "//external:io_bazel_rules_scala/dependency/scalaz/scalaz_effect",
            "//external:io_bazel_rules_scala/dependency/scalaz/scalaz_core",
            "//external:io_bazel_rules_scala/dependency/scala/scala_xml",
            "//external:io_bazel_rules_scala/dependency/scala/parser_combinators",
            "//external:io_bazel_rules_scala/dependency/scala/scala_library",
            "//external:io_bazel_rules_scala/dependency/scala/scala_reflect",
            "//external:io_bazel_rules_scala/dependency/specs2/specs2_junit"],
)