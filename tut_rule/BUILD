load("@io_bazel_rules_scala//scala:providers.bzl", "declare_deps_provider")
load("@io_bazel_rules_scala//tut_rule/toolchain:toolchain.bzl", "export_tut_deps", "tut_toolchain")

tut_toolchain(
    name = "tut_toolchain_impl",
    visibility = ["//visibility:public"],
)

toolchain(
    name = "tut_toolchain",
    toolchain = ":tut_toolchain_impl",
    toolchain_type = "//tut_rule/toolchain:tut_toolchain_type",
)

declare_deps_provider(
    name = "tut_core_provider",
    deps_id = "tut_core",
    deps = ["@io_bazel_rules_scala_org_tpolecat_tut_core"],
)

export_tut_deps(
    name = "tut_core",
    deps_id = "tut_core",
    visibility = ["//visibility:public"],
)
