load("//specs2:specs2.bzl", _repositories = "specs2_repositories")

def specs2_repositories():
    _repositories()

def specs2_toolchain():
    native.register_toolchain("//testing:specs2_toolchain")