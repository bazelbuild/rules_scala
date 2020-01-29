load("@io_bazel_rules_scala//scala_proto:scala_proto.bzl", "scalapb_proto_library")

scalapb_proto_library(
    name = "sample_scala_proto",
    visibility = ["//visibility:public"],
    deps = ["@proto_cross_repo_boundary//:sample_proto"],
)
