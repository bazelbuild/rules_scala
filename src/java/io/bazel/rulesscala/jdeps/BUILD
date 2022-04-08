load("@rules_java//java:defs.bzl", "java_library")

java_library(
    name = "jdeps",
    srcs = ["JdepsWriter.java"],
    visibility = ["//visibility:public"],
    deps = [
        "@bazel_tools//src/main/protobuf:deps_java_proto",
        "@com_google_protobuf//:protobuf_java",
    ],
)
