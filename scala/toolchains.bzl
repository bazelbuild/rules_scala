load("@io_bazel_rules_scala_config//:config.bzl", "SCALA_VERSIONS")
load("//scala/versions:versions.bzl", "sanitize_version")

def scala_register_toolchains():
    for scala_version in SCALA_VERSIONS:
        native.register_toolchains(
            "@io_bazel_rules_scala//scala:%s_toolchain" % sanitize_version(scala_version),
        )
    native.register_toolchains(
        "@io_bazel_rules_scala//scala:default_toolchain",
    )

def scala_register_unused_deps_toolchains():
    native.register_toolchains(
        "@io_bazel_rules_scala//scala:unused_dependency_checker_error_toolchain",
    )
