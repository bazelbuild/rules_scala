load("//scalatest:scalatest.bzl", _repositories = "scalatest_repositories")
load("@io_bazel_rules_scala_config//:config.bzl", "SCALA_VERSIONS")
load("@io_bazel_rules_scala//scala:scala_cross_version.bzl", "sanitize_version")

def scalatest_repositories():
    _repositories()

def scalatest_toolchain():
    for scala_version in SCALA_VERSIONS:
        native.register_toolchains("@io_bazel_rules_scala//testing:scalatest_toolchain_" + sanitize_version(scala_version))
