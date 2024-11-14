load("//scalatest:scalatest.bzl", _repositories = "scalatest_repositories")
load("//scala:scala_cross_version.bzl", "version_suffix")
load("@io_bazel_rules_scala_config//:config.bzl", "SCALA_VERSIONS")

def scalatest_repositories():
    _repositories()

def scalatest_toolchain():
    for scala_version in SCALA_VERSIONS:
        native.register_toolchains(str(Label(
            "//testing:scalatest_toolchain" +
            version_suffix(scala_version),
        )))
