load(
    "@com_google_protobuf//bazel:java_proto_library.bzl",
    "java_proto_library",
)
load("@rules_proto//proto:defs.bzl", "proto_library")

proto_library(
    name = "diagnostics_proto",
    srcs = ["diagnostics.proto"],
)

java_proto_library(
    name = "diagnostics_java_proto",
    visibility = ["//visibility:public"],
    deps = [":diagnostics_proto"],
)
