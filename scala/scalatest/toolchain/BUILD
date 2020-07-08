load("@io_bazel_rules_scala//scala/toolchains:toolchains.bzl", "declare_deps_toolchain")
load("@io_bazel_rules_scala//scala:providers.bzl", "declare_deps_provider")
load("//scala/scalatest/toolchain:toolchain.bzl", "scalatest_toolchain_deps")

toolchain_type(
    name = "scalatest_toolchain_type",
    visibility = ["//visibility:public"],
)

toolchain(
    name = "scalatest_toolchain",
    toolchain = ":scalatest_toolchain_impl",
    toolchain_type = ":scalatest_toolchain_type",
    visibility = ["//visibility:public"],
)

declare_deps_provider(
    name = "scalatest_deps_provider",
    deps = [
        "//external:io_bazel_rules_scala/dependency/scala/scalactic/scalactic",
        "//external:io_bazel_rules_scala/dependency/scala/scalatest/scalatest",
    ],
)

declare_deps_toolchain(
    name = "scalatest_toolchain_impl",
    dep_providers = {
        ":scalatest_deps_provider": "scalatest_classpath",
    },
    visibility = ["//visibility:public"],
)

scalatest_toolchain_deps(
    name = "scalatest_classapth",
    provider_id = "scalatest_classpath",
    visibility = ["//visibility:public"],
)
