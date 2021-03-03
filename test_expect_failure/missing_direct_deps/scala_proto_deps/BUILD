load("//scala:scala.bzl", "scala_library")
load("//scala:scala_import.bzl", "scala_import")
load("//scala_proto:scala_proto.bzl", "scala_proto_library")

proto_library(
    name = "proto",
    srcs = ["some.proto"],
)

scala_proto_library(
    name = "scala_proto",
    deps = [":proto"],
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
    deps = [":scala_proto"],
)
