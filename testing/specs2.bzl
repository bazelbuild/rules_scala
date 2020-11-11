load("//specs2:specs2.bzl", _repositories = "specs2_repositories")

def specs2_repositories():
    _repositories()

def specs2_toolchain():
    native.register_toolchain("@io_bazel_rules_scala//testing:specs2_toolchain")