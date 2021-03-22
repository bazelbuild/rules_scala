load("@rules_proto//proto:defs.bzl", "proto_library")
load("@rules_java//java:defs.bzl", "java_library")
load("//scala:scala.bzl", "scala_library")
load("//scala_proto:scala_proto.bzl", "scala_proto_library")
load("//scala_proto:scala_proto_toolchain.bzl", "scala_proto_toolchain")
load(":customized_scala_proto.bzl", "custom_stamping_convention", "custom_stamping_scala_proto_library")

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

custom_stamping_convention(
    name = "phase_custom_stamping",
)

custom_stamping_scala_proto_library(
    name = "some_proto_custom_suffix",
    deps = [":some_proto"],
)

# java library is used to prevent label collection and force looking into jar stamp
java_library(
    name = "custom_transitive",
    srcs = ["UseTestMessage.java"],
    deps = [":some_proto_custom_suffix"],
)

scala_library(
    name = "uses_transitive_some_proto_custom_suffix",
    srcs = ["UseScalaProtoIndirectly.scala"],
    deps = [":custom_transitive"],
)
