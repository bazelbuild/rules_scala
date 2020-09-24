load("@rules_proto//proto:defs.bzl", "proto_library")
load(
    "//scala_proto:scala_proto_extended.bzl",
    "scala_proto_library_extended",
)
load(
    "//scala:scala.bzl",
    "scala_binary",
    "scala_library",
    "scala_test",
)

proto_library(
    name = "scalapb",
    srcs = ["scalapb.proto"],
    deps = ["@com_google_protobuf//:descriptor_proto"],
)

proto_library(
    name = "proto1",
    srcs = ["proto1.proto"],
    deps = [":scalapb"],
)

proto_library(
    name = "proto2",
    srcs = ["proto2.proto"],
    deps = [
        ":proto1",
        ":scalapb",
    ],
)

scala_library(
    name = "custom_import_lib",
    srcs = ["CustomImport.scala"],
)

scala_proto_library_extended(
    name = "proto1_test",
    proto = ":proto1",
    deps = [
        ":custom_import_lib",
    ],
)

scala_proto_library_extended(
    name = "proto2_test",
    proto = ":proto2",
    deps = [
        ":proto1_test"
    ],
)
