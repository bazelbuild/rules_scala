load(
    ":jvm_export_toolchain.bzl",
    _export_scalac_repositories_from_toolchain_to_jvm = "export_scalac_repositories_from_toolchain_to_jvm",
)

_export_scalac_repositories_from_toolchain_to_jvm(
    name = "exported_scalac_repositories_from_toolchain_to_jvm",
)

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
        ":exported_scalac_repositories_from_toolchain_to_jvm",
        "@io_bazel_rules_scala//src/java/com/google/devtools/build/lib:worker",
        "@io_bazel_rules_scala//src/java/io/bazel/rulesscala/jar",
        "@io_bazel_rules_scala//src/java/io/bazel/rulesscala/worker",
        "//external:io_bazel_rules_scala/dependency/scalac_rules_commons_io",
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
