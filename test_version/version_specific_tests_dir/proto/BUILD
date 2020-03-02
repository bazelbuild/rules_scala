load("@rules_java//java:defs.bzl", "java_proto_library")
load(
    "@io_bazel_rules_scala//scala_proto:scala_proto.bzl",
    "scala_proto_library",
)
load("@rules_proto//proto:defs.bzl", "proto_library")

proto_library(
    name = "test2",
    srcs = ["test2.proto"],
    visibility = ["//visibility:public"],
    deps = ["//proto2:test"],
)

proto_library(
    name = "test3",
    srcs = ["test3.proto"],
    visibility = ["//visibility:public"],
    deps = ["//proto2:test"],
)

proto_library(
    name = "test_service",
    srcs = ["test_service.proto"],
    visibility = ["//visibility:public"],
    deps = [
        ":test2",
        ":test3",
        "//proto2:test",
    ],
)

scala_proto_library(
    name = "test_proto_nogrpc",
    visibility = ["//visibility:public"],
    deps = [":test2"],
)

java_proto_library(
    name = "test_proto_java_lib",
    deps = [
        ":test2",
        "//proto2:test",
    ],
)

scala_proto_library(
    name = "test_proto_java_conversions",
    visibility = ["//visibility:public"],
    deps = [
        ":test2",
        ":test_proto_java_lib",
        "//proto2:test",
    ],
)

scala_proto_library(
    name = "test_proto",
    visibility = ["//visibility:public"],
    deps = [":test_service"],
)
