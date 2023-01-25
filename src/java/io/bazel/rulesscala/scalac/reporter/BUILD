load("@rules_proto//proto:defs.bzl", "proto_library")
load("@rules_java//java:defs.bzl", "java_library", "java_proto_library")
load("@io_bazel_rules_scala_config//:config.bzl", "SCALA_MAJOR_VERSION")

java_library(
    name = "reporter",
    srcs = [
        "DepsTrackingReporter.java",
        "ProtoReporter.java",
    ] if SCALA_MAJOR_VERSION.startswith("2") else ["PlaceholderForEmptyScala3Lib.java"],
    visibility = ["//visibility:public"],
    deps = [
        ":scala_deps_java_proto",
        "//scala/private/toolchain_deps:scala_compile_classpath",
        "//src/java/io/bazel/rulesscala/scalac/compileoptions",
        "@io_bazel_rules_scala//src/protobuf/io/bazel/rules_scala:diagnostics_java_proto",
    ],
)

proto_library(
    name = "scala_deps_proto",
    srcs = ["scala_deps.proto"],
    visibility = ["//visibility:public"],
)

java_proto_library(
    name = "scala_deps_java_proto",
    visibility = ["//visibility:public"],
    deps = [":scala_deps_proto"],
)
