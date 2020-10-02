load("//junit:junit.bzl", _repositories = "junit_repositories")

def junit_repositories():
    _repositories()

def junit_toolchain():
    native.register_toolchains("@io_bazel_rules_scala//testing:junit_toolchain")
