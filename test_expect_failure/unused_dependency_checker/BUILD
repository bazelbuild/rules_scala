load("//scala:scala_toolchain.bzl", "scala_toolchain")
load("//scala:scala.bzl", "scala_library")

scala_toolchain(
    name = "failing_toolchain_impl",
    unused_dependency_checker_mode = "error",
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
    srcs = ["A.scala"],
    unused_dependency_checker_mode = "error",
    deps = [":B"],
)

scala_library(
    name = "toolchain_failing_build",
    srcs = ["A.scala"],
    deps = [":B"],
)

scala_library(
    name = "toolchain_override",
    srcs = ["A.scala"],
    unused_dependency_checker_mode = "off",
    deps = [":B"],
)

scala_library(
    name = "B",
    srcs = ["B.scala"],
)
