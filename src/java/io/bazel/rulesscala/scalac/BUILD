load("@rules_java//java:defs.bzl", "java_binary")
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
    main_class = "io.bazel.rulesscala.scalac.ScalacWorker",
    visibility = ["//visibility:public"],
    deps = [
        ":exported_scalac_repositories_from_toolchain_to_jvm",
        "//external:io_bazel_rules_scala/dependency/commons_io/commons_io",
        "//third_party/bazel/src/main/protobuf:worker_protocol_java_proto",
        "@io_bazel_rules_scala//src/java/io/bazel/rulesscala/jar",
        "@io_bazel_rules_scala//src/java/io/bazel/rulesscala/worker",
        "@io_bazel_rules_scala//src/protobuf/io/bazel/rules_scala:diagnostics_java_proto",
    ],
)

filegroup(
    name = "scalac_files",
    srcs = [
        "CompileOptions.java",
        "ProtoReporter.java",
        "CompositeReporter.java",
        "ReportableMainClass.java",
        "Resource.java",
        "ScalacWorker.java",
    ],
    visibility = ["//visibility:public"],
)
