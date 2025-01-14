load("//scala:scala_cross_version.bzl", "version_suffix")
load("//specs2:specs2_junit.bzl", _repositories = "specs2_junit_repositories")
load("@io_bazel_rules_scala_config//:config.bzl", "SCALA_VERSIONS")

def specs2_junit_repositories():
    _repositories()

def specs2_junit_toolchain():
    for scala_version in SCALA_VERSIONS:
        native.register_toolchains(str(Label(
            "//testing:specs2_junit_toolchain" + version_suffix(scala_version),
        )))
