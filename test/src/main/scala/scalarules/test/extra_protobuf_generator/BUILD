load("//scala:scala.bzl", "scala_library")
load("//scala:scala_cross_version_select.bzl", "select_for_scala_version")

scala_library(
    name = "extra_protobuf_generator",
    srcs = select_for_scala_version(
        any_2_11 = ["ProtobufAdapter_2_11.scala"],
        since_2_12 = ["ProtobufAdapter.scala"],
    ) + ["ExtraProtobufGenerator.scala"],
    visibility = ["//visibility:public"],
    deps = [
        "//scala_proto:scalapb_worker_deps",
    ],
)
