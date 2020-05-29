load("@rules_java//java:defs.bzl", "java_library")
load("//scala_proto:scala_proto_toolchain.bzl", "scala_proto_toolchain")
load("//scala_proto:default_dep_sets.bzl", "DEFAULT_SCALAPB_COMPILE_DEPS", "DEFAULT_SCALAPB_GRPC_DEPS")

toolchain_type(
    name = "toolchain_type",
    visibility = ["//visibility:public"],
)

scala_proto_toolchain(
    name = "default_toolchain_impl",
    visibility = ["//visibility:public"],
    with_flat_package = False,
    with_grpc = True,
    with_single_line_to_string = False,
)

toolchain(
    name = "default_toolchain",
    toolchain = ":default_toolchain_impl",
    toolchain_type = "@io_bazel_rules_scala//scala_proto:toolchain_type",
    visibility = ["//visibility:public"],
)

scala_proto_toolchain(
    name = "enable_all_options_toolchain_impl",
    visibility = ["//visibility:public"],
    with_flat_package = True,
    with_grpc = True,
    # with_java=True,
    with_single_line_to_string = True,
)

toolchain(
    name = "enable_all_options_toolchain",
    toolchain = ":enable_all_options_toolchain_impl",
    toolchain_type = "@io_bazel_rules_scala//scala_proto:toolchain_type",
    visibility = ["//visibility:public"],
)

java_library(
    name = "default_scalapb_compile_dependencies",
    visibility = ["//visibility:public"],
    exports = DEFAULT_SCALAPB_COMPILE_DEPS,
)

java_library(
    name = "default_scalapb_grpc_dependencies",
    visibility = ["//visibility:public"],
    exports = DEFAULT_SCALAPB_GRPC_DEPS,
)
