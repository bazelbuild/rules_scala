load("@rules_proto//proto:defs.bzl", "proto_library")
load("@rules_java//java:defs.bzl", "java_library", "java_proto_library")
load("@io_bazel_rules_scala_config//:config.bzl", "SCALA_MAJOR_VERSION", "SCALA_MINOR_VERSION")

java_library(
    name = "reporter",
    srcs = [
        "//src/java/io/bazel/rulesscala/scalac/deps_tracking_reporter",
        "before_2_12_13/ProtoReporter.java",
    ] if SCALA_MAJOR_VERSION.startswith("2.11") or (SCALA_MAJOR_VERSION.startswith("2.12") and int(SCALA_MINOR_VERSION) < 13) else [
        "//src/java/io/bazel/rulesscala/scalac/deps_tracking_reporter",
        "after_2_12_13_and_before_2_13_12/ProtoReporter.java",
    ] if ((SCALA_MAJOR_VERSION.startswith("2.12") and int(SCALA_MINOR_VERSION) >= 13) or (SCALA_MAJOR_VERSION.startswith("2.13") and int(SCALA_MINOR_VERSION) < 12)) else [
        "//src/java/io/bazel/rulesscala/scalac/deps_tracking_reporter",
        "after_2_13_12/ProtoReporter.java",
    ] if (SCALA_MAJOR_VERSION.startswith("2.13") and int(SCALA_MINOR_VERSION) >= 12) else ["PlaceholderForEmptyScala3Lib.java"],
    visibility = ["//visibility:public"],
    deps = [
        ":scala_deps_java_proto",
        "//scala/private/toolchain_deps:scala_compile_classpath",
        "//src/java/io/bazel/rulesscala/scalac/compileoptions",
        "@io_bazel_rules_scala//src/protobuf/io/bazel/rules_scala:diagnostics_java_proto",
    ],
)

java_library(
    name = "reporter_before_2_12_13",
    srcs = [
        "before_2_12_13/ProtoReporter.java",
        "//src/java/io/bazel/rulesscala/scalac/deps_tracking_reporter:deps_tracking_reporter_before_2_12_13",
    ],
    visibility = ["//visibility:public"],
    deps = [
        ":scala_deps_java_proto",
        "//scala/private/toolchain_deps:scala_compile_classpath",
        "//src/java/io/bazel/rulesscala/scalac/compileoptions",
        "@io_bazel_rules_scala//src/protobuf/io/bazel/rules_scala:diagnostics_java_proto",
    ],
)

java_library(
    name = "reporter_after_2_12_13_and_before_2_13_12",
    srcs = [
        "after_2_12_13_and_before_2_13_12/ProtoReporter.java",
        "//src/java/io/bazel/rulesscala/scalac/deps_tracking_reporter:deps_tracking_reporter_after_2_12_13_and_before_2_13_12",
    ],
    visibility = ["//visibility:public"],
    deps = [
        ":scala_deps_java_proto",
        "//scala/private/toolchain_deps:scala_compile_classpath",
        "//src/java/io/bazel/rulesscala/scalac/compileoptions",
        "@io_bazel_rules_scala//src/protobuf/io/bazel/rules_scala:diagnostics_java_proto",
    ],
)

java_library(
    name = "reporter_after_2_13_12",
    srcs = [
        "after_2_13_12/ProtoReporter.java",
        "//src/java/io/bazel/rulesscala/scalac/deps_tracking_reporter:deps_tracking_reporter_after_2_13_12",
    ],
    visibility = ["//visibility:public"],
    deps = [
        ":scala_deps_java_proto",
        "//scala/private/toolchain_deps:scala_compile_classpath",
        "//src/java/io/bazel/rulesscala/scalac/compileoptions",
        "@io_bazel_rules_scala//src/protobuf/io/bazel/rules_scala:diagnostics_java_proto",
    ],
)

java_library(
    name = "reporter_3",
    srcs = ["PlaceholderForEmptyScala3Lib.java"],
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
