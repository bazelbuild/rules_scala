load("@rules_java//java:defs.bzl", "java_library")

java_library(
    name = "runner",
    srcs = ["Runner.java"],
    visibility = ["//visibility:public"],
    deps = [
        "//external:io_bazel_rules_scala/dependency/scalatest/scalatest",
        "@bazel_tools//tools/java/runfiles",
    ],
)
