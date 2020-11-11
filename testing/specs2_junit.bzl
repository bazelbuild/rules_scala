load("//specs2:specs2_junit.bzl", _repositories = "specs2_junit_repositories")

def specs2_repositories():
    _repositories()

def specs2_toolchain():
    native.register_toolchain("@io_bazel_rules_scala//testing:specs2_junit_toolchain")
