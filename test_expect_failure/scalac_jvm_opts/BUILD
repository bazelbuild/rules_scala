load("//scala:scala_toolchain.bzl", "scala_toolchain")
load("//scala:scala.bzl", "scala_library")

scala_toolchain(
    name = "failing_toolchain_impl",
    # This will fail because 1 meg isn't enough
    scalac_jvm_flags = ["-Xmx1M"],
    visibility = ["//visibility:public"],
)

scala_toolchain(
    name = "passing_toolchain_impl",
    # This will fail because 1 meg isn't enough
    scalac_jvm_flags = ["-Xmx1G"],
    visibility = ["//visibility:public"],
)

toolchain(
    name = "failing_scala_toolchain",
    toolchain = "failing_toolchain_impl",
    toolchain_type = "@io_bazel_rules_scala//scala:toolchain_type",
    visibility = ["//visibility:public"],
)

toolchain(
    name = "passing_scala_toolchain",
    toolchain = "passing_toolchain_impl",
    toolchain_type = "@io_bazel_rules_scala//scala:toolchain_type",
    visibility = ["//visibility:public"],
)

scala_library(
    name = "empty_build",
    srcs = ["Empty.scala"],
)
