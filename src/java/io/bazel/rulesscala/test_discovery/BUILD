load("//scala:scala.bzl", "scala_library")

scala_library(
    name = "test_discovery",
    srcs = [
        "DiscoveredTestSuite.scala",
        "FilteredRunnerBuilder.scala",
    ],
    visibility = ["//visibility:public"],
    deps = ["@io_bazel_rules_scala//testing/toolchain:junit_classpath"],
)
