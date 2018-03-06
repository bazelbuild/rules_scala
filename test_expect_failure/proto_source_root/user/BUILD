load("//scala_proto:scala_proto.bzl",
    "scalapb_proto_library")

proto_library(
    name = "user",
    srcs = glob(["*.proto"]),
    deps = ["//test_expect_failure/proto_source_root/dependency"],
    proto_source_root = package_name(),
)

scalapb_proto_library(
    name = "user_scala",
    deps = [":user"],
    visibility = ["//visibility:public"],
)
