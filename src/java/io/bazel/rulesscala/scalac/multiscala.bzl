load("@io_bazel_rules_scala_configuration//:configuration.bzl",
     _multiscala_enabled = "multiscala_enabled",
     _configuration = "configuration",
     _versions = "versions",
     _versioned_name = "versioned_name",
)
load(
    ":jvm_export_toolchain.bzl",
    _export_scalac_repositories_from_toolchain_to_jvm = "export_scalac_repositories_from_toolchain_to_jvm",
)

def load_multiscala():
    if not _multiscala_enabled(): return

    for version_configuration in _versions():
        fail(version_configuration)

        _export_scalac_repositories_from_toolchain_to_jvm(
            name = _versioned_name(
                "exported_scalac_repositories_from_toolchain_to_jvm",
                version_configuration
            ),
            toolchains = version_configuration["bootstrap_toolchain"],
        )

        native.java_binary(
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
                "//external:io_bazel_rules_scala/dependency/scalac_rules_commons_io",
                "//third_party/bazel/src/main/protobuf:worker_protocol_java_proto",
                "@io_bazel_rules_scala//src/java/io/bazel/rulesscala/jar",
                "@io_bazel_rules_scala//src/java/io/bazel/rulesscala/worker",
            ],
        )
