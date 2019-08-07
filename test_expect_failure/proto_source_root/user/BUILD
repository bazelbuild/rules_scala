load(
    "//scala_proto:scala_proto.bzl",
    "scalapb_proto_library",
)

proto_library(
    name = "user",
    srcs = glob(["*.proto"]),
    strip_import_prefix = "",
    deps = ["//test_expect_failure/proto_source_root/dependency"],
)

scalapb_proto_library(
    name = "user_scala",
    visibility = ["//visibility:public"],
    deps = [":user"],
)
