load("@rules_proto//proto:defs.bzl", "proto_library")
load(
    "//scala_proto:scala_proto.bzl",
    "scala_proto_library",
)

genrule(
    name = "generated",
    srcs = ["test.proto"],
    outs = ["generated.proto"],
    cmd = "cp $(SRCS) \"$@\"",
)

proto_library(
    name = "generated-proto-lib",
    srcs = [":generated"],
    visibility = ["//visibility:public"],
)

scala_proto_library(
    name = "test_generated_proto",
    visibility = ["//visibility:public"],
    deps = [":generated-proto-lib"],
)
