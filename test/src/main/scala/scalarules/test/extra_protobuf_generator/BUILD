load("//scala:scala.bzl", "scala_library")

scala_library(
    name = "extra_protobuf_generator",
    srcs = ["ExtraProtobufGenerator.scala"],
    deps = [
            "//external:io_bazel_rules_scala/dependency/proto/protoc_bridge",
        "//external:io_bazel_rules_scala/dependency/proto/scalapb_plugin",
            "//external:io_bazel_rules_scala/dependency/com_google_protobuf/protobuf_java",

    ],
        visibility = ["//visibility:public"],


)
