load(":multiscala.bzl", "load_multiscala")
load_multiscala()

java_library(
    name = "runner",
    srcs = ["Runner.java"],
    visibility = ["//visibility:public"],
    deps = [
        "//external:io_bazel_rules_scala/dependency/scalatest/scalatest",
        "@bazel_tools//tools/java/runfiles",
    ],
)
