load("//scala:scala_toolchain.bzl", "scala_toolchain")
load("//scala:scala.bzl", "scala_test")

scala_toolchain(
    name = "passing_toolchain_impl",
    jacocorunner = "@bazel_tools//tools/jdk:JacocoCoverage",
    visibility = ["//visibility:public"],
)

toolchain(
    name = "passing_scala_toolchain",
    toolchain = "passing_toolchain_impl",
    toolchain_type = "//scala:toolchain_type",
    visibility = ["//visibility:public"],
)

scala_test(
    name = "empty_test",
    srcs = ["EmptyTest.scala"],
)
