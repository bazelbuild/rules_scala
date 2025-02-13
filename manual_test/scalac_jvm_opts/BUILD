load("@rules_proto//proto:defs.bzl", "proto_library")
load("//scala:scala_toolchain.bzl", "scala_toolchain")
load("//scala:scala.bzl", "scala_library")
load("//scala_proto:scala_proto.bzl", "scala_proto_library")

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

scala_toolchain(
    name = "passing_toolchain_impl",
    # This will pass because 1G is enough
    scalac_jvm_flags = ["-Xmx1G"],
    visibility = ["//visibility:public"],
)

toolchain(
    name = "passing_scala_toolchain",
    toolchain = "passing_toolchain_impl",
    toolchain_type = "//scala:toolchain_type",
    visibility = ["//visibility:public"],
)

scala_library(
    name = "empty_build",
    srcs = ["Empty.scala"],
)

scala_library(
    name = "empty_overriding_build",
    srcs = ["Empty.scala"],
    # This overrides the option passed in on the toolchain, and should BUILD, even if
    # the `failing_scala_toolchain` is used.
    scalac_jvm_flags = ["-Xmx1G"],
)

proto_library(
    name = "test",
    srcs = ["test.proto"],
    visibility = ["//visibility:public"],
)

# This is a regression test for a bug that broke compiling scalapb targets when
# `scalac_jvm_flags` was set on the toolchain.
scala_proto_library(
    name = "proto",
    visibility = ["//visibility:public"],
    deps = [":test"],
)
