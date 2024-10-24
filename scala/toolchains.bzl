load("@io_bazel_rules_scala_config//:config.bzl", "SCALA_VERSIONS")
load("@io_bazel_rules_scala//scala:scala_cross_version.bzl", "version_suffix")

def scala_register_toolchains():
    for scala_version in SCALA_VERSIONS:
        native.register_toolchains(
            "@io_bazel_rules_scala_toolchains//scala:toolchain" +
            version_suffix(scala_version),
        )

def scala_register_unused_deps_toolchains():
    native.register_toolchains(
        str(Label("//scala:unused_dependency_checker_error_toolchain")),
    )
