load("@rules_java//java:defs.bzl", "java_binary")

java_binary(
    name = "instrumenter",
    srcs = [
        "@io_bazel_rules_scala//src/java/io/bazel/rulesscala/coverage/instrumenter:instrumenter_files",
    ],
    javacopts = [
        "-source 1.8",
        "-target 1.8",
    ],
    main_class = "io.bazel.rulesscala.coverage.instrumenter.JacocoInstrumenter",
    visibility = ["//visibility:public"],
    deps = [
        ":directory_utils",
        "//third_party/bazel/src/main/protobuf:worker_protocol_java_proto",
        "@bazel_tools//tools/jdk:JacocoCoverage",
        "@io_bazel_rules_scala//src/java/io/bazel/rulesscala/jar",
        "@io_bazel_rules_scala//src/java/io/bazel/rulesscala/worker",
    ],
)

java_library(
    name = "directory_utils",
    srcs = [
        "@io_bazel_rules_scala//src/java/io/bazel/rulesscala/coverage/instrumenter:directory_utils_files",
    ],
    javacopts = [
        "-source 1.8",
        "-target 1.8",
    ],
    visibility = ["//visibility:public"],
)

filegroup(
    name = "instrumenter_files",
    srcs = [
        "JacocoInstrumenter.java",
    ],
    visibility = ["//visibility:public"],
)

filegroup(
    name = "directory_utils_files",
    srcs = [
        "DirectoryUtils.java",
    ],
    visibility = ["//visibility:public"],
)
