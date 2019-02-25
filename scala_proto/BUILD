load("//scala_proto:scala_proto_toolchain.bzl", "scala_proto_toolchain")

toolchain_type(
    name = "toolchain_type",
    visibility = ["//visibility:public"],
)

scala_proto_toolchain(
    name = "default_toolchain_impl",
    with_grpc = False,
    with_flat_package=False,
    # with_java=False,
    with_single_line_to_string=False,
    visibility = ["//visibility:public"],
)

toolchain(
    name = "default_toolchain",
    toolchain = ":default_toolchain_impl",
    toolchain_type = "@io_bazel_rules_scala//scala_proto:toolchain_type",
    visibility = ["//visibility:public"],
)


scala_proto_toolchain(
    name = "enable_all_options_toolchain_impl",
    with_grpc = True,
    with_flat_package=True,
    # with_java=True,
    with_single_line_to_string=True,
    visibility = ["//visibility:public"],
)

toolchain(
    name = "enable_all_options_toolchain",
    toolchain = ":enable_all_options_toolchain_impl",
    toolchain_type = "@io_bazel_rules_scala//scala_proto:toolchain_type",
    visibility = ["//visibility:public"],
)
