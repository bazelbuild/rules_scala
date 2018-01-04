load("//scala:scala_toolchain.bzl", "scala_toolchain")

#call scala toolchain
scala_toolchain(
      name = 'toolchain_impl',
      scalacopts = [],
      visibility = ["//visibility:public"]
    )
    
toolchain_type(
    name = "toolchain_type",
    visibility = ["//visibility:public"]
)

toolchain(
    name = 'toolchain',
    toolchain_type = '@io_bazel_rules_scala//scala:toolchain_type',
    toolchain = ':toolchain_impl',
    visibility = ["//visibility:public"]
)
