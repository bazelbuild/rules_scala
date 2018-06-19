load(
    "//scala_proto:scala_proto.bzl",
    "scalapb_proto_library",
)

proto_library(
    name = "test2",
    srcs = ["test2.proto"],
    visibility = ["//visibility:public"],
    deps = ["//test/proto2:test"],
)

proto_library(
    name = "test3",
    srcs = ["test3.proto"],
    visibility = ["//visibility:public"],
    deps = ["//test/proto2:test"],
)

proto_library(
    name = "test_service",
    srcs = ["test_service.proto"],
    visibility = ["//visibility:public"],
    deps = [
        ":test2",
        ":test3",
        "//test/proto2:test",
    ],
)

scalapb_proto_library(
    name = "test_proto_nogrpc",
    visibility = ["//visibility:public"],
    deps = [":test2"],
)

java_proto_library(
    name = "test_proto_java_lib",
    deps = [
        ":test2",
        "//test/proto2:test",
    ],
)

scalapb_proto_library(
    name = "test_proto_java_conversions",
    visibility = ["//visibility:public"],
    with_flat_package = True,
    with_java = True,
    deps = [
        ":test2",
        ":test_proto_java_lib",
        "//test/proto2:test",
    ],
)

scalapb_proto_library(
    name = "test_proto",
    visibility = ["//visibility:public"],
    with_grpc = True,
    deps = [":test_service"],
)
