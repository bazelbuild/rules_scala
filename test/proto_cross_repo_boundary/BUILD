load("@io_bazel_rules_scala//scala_proto:scala_proto.bzl", "scalapb_proto_library")

scalapb_proto_library(
    name = "build_event_stream_scala_proto",
    visibility = ["//visibility:public"],
    deps = ["@io_bazel//src/main/java/com/google/devtools/build/lib/buildeventstream/proto:build_event_stream_proto"],
)

scalapb_proto_library(
    name = "build_scala_proto",
    visibility = ["//visibility:public"],
    deps = ["@io_bazel//src/main/protobuf:build_proto"],
)
