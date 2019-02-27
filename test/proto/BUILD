load(
    "//scala_proto:scala_proto.bzl",
    "scalapb_proto_library",
    "scala_proto_srcjar",
    "scala_proto_gen",
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
    name = "test_external_dep_proto",
    srcs = ["test_external_dep.proto"],
    visibility = ["//visibility:public"],
    deps = [
        "@com_google_protobuf//:wrappers_proto",
    ],
)

scalapb_proto_library(
    name = "test_external_dep",
    visibility = ["//visibility:public"],
    deps = [":test_external_dep_proto"],
)

# Test that the `proto_source_root` attribute is handled properly
proto_library(
    name = "proto_source_root",
    proto_source_root = native.package_name(),
    srcs = ["different_root.proto", "different_root2.proto"],
    visibility = ["//visibility:public"],
)

scalapb_proto_library(
    name = "test_proto_source_root",
    visibility = ["//visibility:public"],
    deps = [":proto_source_root"],
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

        "//test/proto2:test",
    ],
    java_conversions_deps = [":test_proto_java_lib"]
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
    name = "test2_proto_scala_with_blacklisted_test1_proto_scala",
    deps = [":test2"],
    blacklisted_protos = ["//test/proto2:test"],
    generator = "@io_bazel_rules_scala//src/scala/scripts:scalapb_generator")

scala_library(
    name = "lib_scala_should_fail_on_duplicated_sources_unless_duplicates_are_blacklisted",
    srcs = [
        ":test1_proto_scala",
        ":test2_proto_scala_with_blacklisted_test1_proto_scala"],
    deps = [
        "@com_google_protobuf//:protobuf_java",
        "@scala_proto_rules_scalapb_lenses",
        "@scala_proto_rules_scalapb_runtime"])

scala_proto_gen(
    name = "a_proto_scala",
    deps = ["//test/proto2:test"],
    plugin = "@io_bazel_rules_scala//src/scala/scripts:scalapb_plugin")

scala_proto_gen(
    name = "test2_proto_scala",
    deps = [":test2"],
    plugin = "@io_bazel_rules_scala//src/scala/scripts:scalapb_plugin")

scala_proto_gen(
    name = "multi_src_proto_scala",
    deps = [":test2", "//test/proto2:test"],
    plugin = "@io_bazel_rules_scala//src/scala/scripts:scalapb_plugin")

java_proto_library(
    name = "test2_proto_java",
    deps = [":test2", "//test/proto2:test"])
