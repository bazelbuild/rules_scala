load("//scala:scala.bzl", "scala_library")
load("//specs2:specs2_junit.bzl", "specs2_junit_dependencies", "specs2_junit_repositories")

scala_library(
    name = "specs2_test_discovery",
    srcs = [
        "Specs2RunnerBuilder.scala",
    ],
    visibility = ["//visibility:public"],
    deps = ["//src/java/io/bazel/rulesscala/test_discovery:test_discovery",
            "//external:io_bazel_rules_scala/dependency/junit/junit",
            "//external:io_bazel_rules_scala/dependency/specs2/specs2",
            "//external:io_bazel_rules_scala/dependency/specs2/specs2_junit",
            "//external:io_bazel_rules_scala/dependency/scala/scala_xml",
           ]
)