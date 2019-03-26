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
    runtime_deps = [
        "@io_bazel_rules_scala_org_ow2_asm_asm_debug_all",
    ],
    deps = [
        "@io_bazel_rules_scala//src/java/com/google/devtools/build/lib:worker",
        "@io_bazel_rules_scala//src/java/io/bazel/rulesscala/jar",
        "@io_bazel_rules_scala//src/java/io/bazel/rulesscala/worker",
        "@io_bazel_rules_scala_org_jacoco_org_jacoco_core",
    ],
)

filegroup(
    name = "instrumenter_files",
    srcs = [
        "JacocoInstrumenter.java",
    ],
    visibility = ["//visibility:public"],
)
