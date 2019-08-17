load("//scalapb:scalapb_toolchain.bzl", "scalapb_toolchain")
load("//scalapb:default_dep_sets.bzl", "DEFAULT_SCALAPB_COMPILE_DEPS", "DEFAULT_SCALAPB_GRPC_DEPS")


toolchain_type(
    name = "toolchain_type",
    visibility = ["//visibility:public"],
)

scalapb_toolchain(
    name = "default_toolchain_impl",
    with_grpc = True,
    with_flat_package=False,
    with_single_line_to_string=False,
    visibility = ["//visibility:public"],
)

toolchain(
    name = "default_toolchain",
    toolchain = ":default_toolchain_impl",
    toolchain_type = "@io_bazel_rules_scala//scalapb:toolchain_type",
    visibility = ["//visibility:public"],
)


scalapb_toolchain(
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
    toolchain_type = "@io_bazel_rules_scala//scalapb:toolchain_type",
    visibility = ["//visibility:public"],
)


java_library(
    name="default_scalapb_compile_dependencies",
    exports = DEFAULT_SCALAPB_COMPILE_DEPS,
    visibility = ["//visibility:public"],
)

java_library(
    name="default_scalapb_grpc_dependencies",
    exports = DEFAULT_SCALAPB_GRPC_DEPS,
    visibility = ["//visibility:public"],
)
