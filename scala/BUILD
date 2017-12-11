load("//scala:scala_toolchain.bzl", "scala_toolchain")

#call scala toolchain
scala_toolchain(
      name = 'scala_toolchain_impl',
      scalacopts = [],
      visibility = ["//visibility:public"]
    )
    
toolchain(
    name = 'scala_toolchain',
      toolchain_type = '@io_bazel_rules_scala//scala:scala_toolchain.bzl',
      toolchain = ':scala_toolchain_impl',
      visibility = ["//visibility:public"]
    )