load(
    "//scala_proto:scala_proto.bzl",
    "scalapb_proto_library",
    "scala_proto_srcjar"
)

load(
    "//scala:scala.bzl",
    "scala_library",
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

scala_proto_srcjar(
    name = "test1_proto_scala",
    deps = ["//test/proto2:test"],
    generator = "@io_bazel_rules_scala//src/scala/scripts:scalapb_generator")

scala_proto_srcjar(
    name = "test2_proto_scala",
    deps = [":test2"],
    blacklisted_protos = ["//test/proto2:test"],
    generator = "@io_bazel_rules_scala//src/scala/scripts:scalapb_generator")

scala_library(
    name = "lib_scala",
    srcs = [
        ":test1_proto_scala",
        ":test2_proto_scala"],
    deps = [
        "@com_google_protobuf//:protobuf_java",
        "@scala_proto_rules_scalapb_lenses",
        "@scala_proto_rules_scalapb_runtime"])
