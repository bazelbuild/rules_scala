load("@rules_proto//proto:defs.bzl", "proto_library")
load("@rules_java//java:defs.bzl", "java_library")
load("//scala:scala.bzl", "scala_library")
load("//scala_proto:scala_proto.bzl", "scala_proto_library")
load("//scala_proto:scala_proto_toolchain.bzl", "scala_proto_toolchain")

proto_library(
    name = "some_proto",
    srcs = ["some.proto"],
)

scala_proto_library(
    name = "some_scala_proto",
    deps = [":some_proto"],
)

scala_library(
    name = "uses_transitive_scala_proto",
    srcs = ["UseScalaProtoIndirectly.scala"],
    deps = [":transitive"],
)

# java library is used to prevent label collection and force looking into jar stamp
java_library(
    name = "transitive",
    srcs = ["UseTestMessage.java"],
    deps = [":some_scala_proto"],
)

scala_proto_toolchain(
    name = "stamp_by_convention_toolchain_impl",
    stamp_by_convention = True,
)

toolchain(
    name = "stamp_by_convention_toolchain",
    toolchain = ":stamp_by_convention_toolchain_impl",
    toolchain_type = "//scala_proto:toolchain_type",
)