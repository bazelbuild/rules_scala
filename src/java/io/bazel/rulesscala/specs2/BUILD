load("//scala:scala.bzl", "scala_library")

scala_library(
    name = "specs2_test_discovery",
    srcs = [
        "Specs2RunnerBuilder.scala",
        "package.scala",
    ],
    unused_dependency_checker_ignored_targets = [
        "//scala/private/toolchain_deps:scala_xml",
    ],
    visibility = ["//visibility:public"],
    deps = [
        "//scala/private/toolchain_deps:scala_xml",
        "//src/java/io/bazel/rulesscala/test_discovery",
        "//testing/toolchain:junit_classpath",
        "//testing/toolchain:specs2_classpath",
        "//testing/toolchain:specs2_junit_classpath",
    ],
)
