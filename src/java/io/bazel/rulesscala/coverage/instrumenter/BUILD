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
        "//third_party/bazel/src/main/protobuf:worker_protocol_java_proto",
        "@bazel_tools//tools/jdk:JacocoCoverage",
        "@io_bazel_rules_scala//src/java/io/bazel/rulesscala/jar",
        "@io_bazel_rules_scala//src/java/io/bazel/rulesscala/worker",
    ],
)

filegroup(
    name = "instrumenter_files",
    srcs = [
        "JacocoInstrumenter.java",
    ],
    visibility = ["//visibility:public"],
)
