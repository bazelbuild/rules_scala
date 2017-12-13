load("//scala:scala_toolchain.bzl", "scala_toolchain")
load("//scala:scala.bzl", "scala_library")

scala_toolchain(
    name = "failing_scala_toolchain_impl",
    scalacopts = ["-Ywarn-unused"],
    visibility = ["//visibility:public"]
)

toolchain(
    name = "failing_scala_toolchain",
    toolchain_type = "@io_bazel_rules_scala//scala:scala_toolchain_type",
    toolchain = "failing_scala_toolchain_impl",
    visibility = ["//visibility:public"]
)

scala_library(
    name = "failing_build",
    srcs = ["ClassWithUnused.scala"],
    scalacopts = ["-Xfatal-warnings"]
)