load("@rules_proto//proto:defs.bzl", "proto_library")
load("@rules_java//java:defs.bzl", "java_proto_library")

proto_library(
    name = "diagnostics_proto",
    srcs = ["diagnostics.proto"],
)

java_proto_library(
    name = "diagnostics_java_proto",
    visibility = ["//visibility:public"],
    deps = [":diagnostics_proto"],
)
