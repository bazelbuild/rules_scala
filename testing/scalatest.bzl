load("//scalatest:scalatest.bzl", _repositories = "scalatest_repositories")

def scalatest_repositories():
    _repositories()

def scalatest_toolchain():
    native.register_toolchains("@io_bazel_rules_scala//testing:scalatest_toolchain")
