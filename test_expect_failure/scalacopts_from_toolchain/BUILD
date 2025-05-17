load("//scala:scala.bzl", "scala_library")
load("//scala:scala_toolchain.bzl", "scala_toolchain")

scala_toolchain(
    name = "failing_toolchain_impl",
    scalacopts = ["-Ywarn-unused"],
    visibility = ["//visibility:public"],
)

toolchain(
    name = "failing_scala_toolchain",
    toolchain = "failing_toolchain_impl",
    toolchain_type = "//scala:toolchain_type",
    visibility = ["//visibility:public"],
)

scala_library(
    name = "failing_build",
    srcs = ["ClassWithUnused.scala"],
    scalacopts = ["-Xfatal-warnings"],
)
