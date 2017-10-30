load("//scala:scala.bzl", "scala_library")
load("//specs2:specs2_junit.bzl", "specs2_junit_dependencies")

scala_library(
    name = "test_discovery",
    srcs = [
        "DiscoveredTestSuite.scala",
        "FilteredRunnerBuilder.scala",
    ],
    visibility = ["//visibility:public"],
    deps = ["//external:io_bazel_rules_scala/dependency/junit/junit",
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
