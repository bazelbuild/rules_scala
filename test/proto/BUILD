load("//scala_proto:scala_proto.bzl",
    "scalapb_proto_library")

proto_library(
    name = "test2",
    deps = ["//test/proto2:test"],
    srcs = ["test2.proto"],
    visibility = ["//visibility:public"],
)

proto_library(
    name = "test3",
    deps = ["//test/proto2:test"],
    srcs = ["test3.proto"],
    visibility = ["//visibility:public"],
)

proto_library(
    name = "test_service",
    deps = [":test2", ":test3", "//test/proto2:test"],
    srcs = ["test_service.proto"],
    visibility = ["//visibility:public"],
)

scalapb_proto_library(
    name = "test_proto_nogrpc",
    deps = [":test2"],
    visibility = ["//visibility:public"],
)

java_proto_library(
    name = "test_proto_java_lib",
    deps = ["//test/proto2:test"],
)

scalapb_proto_library(
    name = "test_proto_java_conversions",
    deps = [":test2", ":test_proto_java_lib"],
    with_java = True,
    with_flat_package = True,
    visibility = ["//visibility:public"],
)

scalapb_proto_library(
    name = "test_proto",
    with_grpc = True,
    deps = [":test_service"],
    visibility = ["//visibility:public"],
)
