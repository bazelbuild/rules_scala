java_binary(
    name = "scalac",
    srcs = [
        "@io_bazel_rules_scala//src/java/io/bazel/rulesscala/scalac:scalac_files",
    ],
    javacopts = [
        "-source 1.8",
        "-target 1.8",
    ],
    main_class = "io.bazel.rulesscala.scalac.ScalaCInvoker",
    visibility = ["//visibility:public"],
    deps = [
        "@io_bazel_rules_scala//src/java/com/google/devtools/build/lib:worker",
        "@io_bazel_rules_scala//src/java/io/bazel/rulesscala/jar",
        "@io_bazel_rules_scala//src/java/io/bazel/rulesscala/worker",
        "@io_bazel_rules_scala_scala_compiler",
        "@io_bazel_rules_scala_scala_library",
        "@io_bazel_rules_scala_scala_reflect",
        "@scalac_rules_commons_io//jar",
    ],
)

filegroup(
    name = "scalac_files",
    srcs = [
        "CompileOptions.java",
        "Resource.java",
        "ScalaCInvoker.java",
        "ScalacProcessor.java",
    ],
    visibility = ["//visibility:public"],
)
