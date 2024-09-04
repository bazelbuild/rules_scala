load("@rules_proto//proto:defs.bzl", "proto_library")
load("@rules_java//java:defs.bzl", "java_library", "java_proto_library")
load("//scala:scala_cross_version_select.bzl", "select_for_scala_version")

java_library(
    name = "reporter",
    srcs = select_for_scala_version(
        before_2_12_13 = [
            "//src/java/io/bazel/rulesscala/scalac/deps_tracking_reporter",
            "before_2_12_13/ProtoReporter.java",
        ],
        between_2_12_13_and_2_13_12 = [
            "//src/java/io/bazel/rulesscala/scalac/deps_tracking_reporter",
            "after_2_12_13_and_before_2_13_12/ProtoReporter.java",
        ],
        between_2_13_12_and_3 = [
            "//src/java/io/bazel/rulesscala/scalac/deps_tracking_reporter",
            "after_2_13_12_and_before_3/ProtoReporter.java",
        ],
        since_3 = [
            "//src/java/io/bazel/rulesscala/scalac/deps_tracking_reporter",
            "since_3/ProtoReporter.java",
        ],
    ),
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
