licenses(["notice"])  # 3-clause BSD

load("//scala:scala.bzl", "scala_library")

scala_library(
    name = "test_util",
    srcs = [
        "io/bazel/rules_scala/utils/TestUtil.scala",
    ],
    visibility = ["//visibility:public"],
    deps = [
        "//external:io_bazel_rules_scala/dependency/scala/scala_compiler",
        "//external:io_bazel_rules_scala/dependency/scala/scala_reflect",
    ],
)
