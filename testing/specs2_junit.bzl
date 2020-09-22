load("//specs2:specs2_junit.bzl", _repositories = "specs2_junit_repositories")

def specs2_repositories():
    _repositories()

def specs2_toolchain():
    native.register_toolchain("//testing:specs2_junit_toolchain")
