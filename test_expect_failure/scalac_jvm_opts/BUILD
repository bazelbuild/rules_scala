load("//scala:scala.bzl", "scala_library")
load("//scala:scala_toolchain.bzl", "scala_toolchain")

scala_toolchain(
    name = "failing_toolchain_impl",
    # This will fail because 1M isn't enough
    scalac_jvm_flags = ["-Xmx1M"],
    visibility = ["//visibility:public"],
)

toolchain(
    name = "failing_scala_toolchain",
    toolchain = "failing_toolchain_impl",
    toolchain_type = "//scala:toolchain_type",
    visibility = ["//visibility:public"],
)

scala_library(
    name = "empty_build",
    srcs = ["Empty.scala"],
)
