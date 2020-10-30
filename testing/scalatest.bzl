def scalatest_repositories():
    # currently ScalaTest dependencies are already loaded via //scala:scala.bzl#scala_repositories()
    pass

def scalatest_toolchain():
    native.register_toolchains("@io_bazel_rules_scala//testing:scalatest_toolchain")
