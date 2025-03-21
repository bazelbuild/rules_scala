load(
    "@com_google_protobuf//bazel:java_proto_library.bzl",
    "java_proto_library",
)
load("@rules_java//java:java_library.bzl", "java_library")
load("@rules_proto//proto:defs.bzl", "proto_library")
load("//scala:scala_cross_version_select.bzl", "select_for_scala_version")

java_library(
    name = "reporter",
    srcs = select_for_scala_version(
        any_2_13_0 = [
            "before_2_12_13/ProtoReporter.java",
        ],
        before_2_12_13 = [
            "before_2_12_13/ProtoReporter.java",
        ],
        between_2_12_13_and_2_13 = [
            "after_2_12_13_and_before_2_13_12/ProtoReporter.java",
        ],
        between_2_13_12_and_3 = [
            "after_2_13_12/ProtoReporter.java",
        ],
        between_2_13_1_and_2_13_12 = [
            "after_2_12_13_and_before_2_13_12/ProtoReporter.java",
        ],
        between_3_0_and_3_3 = glob(["scala_3/*.java"]) + [
            "since_3_before_3_3/CompilerCompat.java",
        ],
        since_3_3 = glob(["scala_3/*.java"]) + [
            "since_3_3/CompilerCompat.java",
        ],
    ) + ["//src/java/io/bazel/rulesscala/scalac/deps_tracking_reporter"],
    visibility = ["//visibility:public"],
    deps = [
        ":scala_deps_java_proto",
        "//scala/private/toolchain_deps:scala_compile_classpath",
        "//src/java/io/bazel/rulesscala/scalac/compileoptions",
        "//src/protobuf/io/bazel/rules_scala:diagnostics_java_proto",
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
