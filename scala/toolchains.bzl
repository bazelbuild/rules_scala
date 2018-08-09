def scala_register_toolchains():
  native.register_toolchains("@io_bazel_rules_scala//scala:default_toolchain")

def scala_register_toolchains_unused_deps():
  native.register_toolchains(
      "@io_bazel_rules_scala//scala:unused_dependency_error_toolchain")
