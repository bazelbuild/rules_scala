load("@io_bazel_rules_scala//scala:providers.bzl", "declare_deps_provider")
load("//scala/toolchains:toolchains.bzl", "declare_deps_toolchain")
load(":toolchain.bzl", "proto_toolchain_deps")
load("//scala_proto:default_dep_sets.bzl", "DEFAULT_SCALAPB_COMPILE_DEPS", "DEFAULT_SCALAPB_GRPC_DEPS")

toolchain_type(
    name = "proto_toolchain_type",
    visibility = ["//visibility:public"],
)

toolchain(
    name = "proto_toolchain",
    toolchain = ":proto_toolchain_impl",
    toolchain_type = ":proto_toolchain_type",
    visibility = ["//visibility:public"],
)

declare_deps_provider(
    name = "scalapb_compile_deps_provider",
    visibility = ["//visibility:public"],
    deps = DEFAULT_SCALAPB_COMPILE_DEPS,
)

declare_deps_provider(
    name = "scalapb_grpc_deps_provider",
    visibility = ["//visibility:public"],
    deps = DEFAULT_SCALAPB_GRPC_DEPS,
)

declare_deps_toolchain(
    name = "proto_toolchain_impl",
    dep_providers = {
        ":scalapb_compile_deps_provider": "compile_deps",
        ":scalapb_grpc_deps_provider": "grpc_deps",
    },
    visibility = ["//visibility:public"],
)
