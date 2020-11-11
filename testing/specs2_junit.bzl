load("//specs2:specs2_junit.bzl", _repositories = "specs2_junit_repositories")

def specs2_junit_repositories():
    _repositories()

def specs2_junit_toolchain():
    native.register_toolchains("@io_bazel_rules_scala//testing:specs2_junit_toolchain")
