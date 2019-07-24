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
        "@io_bazel_rules_scala//src/java/com/google/devtools/build/lib:worker",
        "@io_bazel_rules_scala//src/java/io/bazel/rulesscala/jar",
        "@io_bazel_rules_scala//src/java/io/bazel/rulesscala/worker",
        "@bazel_tools//tools/jdk:JacocoCoverage",
    ],
)

filegroup(
    name = "instrumenter_files",
    srcs = [
        "JacocoInstrumenter.java",
    ],
    visibility = ["//visibility:public"],
)
