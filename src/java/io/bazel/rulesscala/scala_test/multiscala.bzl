load(
    "@io_bazel_rules_scala_configuration//:configuration.bzl",
    _configuration = "configuration",
    _multiscala_enabled = "multiscala_enabled",
    _versioned_name = "versioned_name",
    _versions = "versions",
)

def load_multiscala():
    if not _multiscala_enabled():
        return

    for version_configuration in _versions():
        native.java_library(
            name = _versioned_name("runner", version_configuration),
            srcs = ["Runner.java"],
            visibility = ["//visibility:public"],
            deps = [
                "//external:io_bazel_rules_scala/dependency/scalatest/scalatest",
                "@bazel_tools//tools/java/runfiles",
            ],
        )
