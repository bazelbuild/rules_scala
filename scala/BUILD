load("//scala:scala_cross_version.bzl", "version_suffix")
load("//scala:scala_toolchain.bzl", "scala_toolchain")
load("@rules_java//java:defs.bzl", "java_import", "java_library")
load("@rules_scala_config//:config.bzl", "SCALA_VERSION")

toolchain_type(
    name = "toolchain_type",
    visibility = ["//visibility:public"],
)

# Alias for backward compatibility
alias(
    name = "default_toolchain",
    actual = (
        "@rules_scala_toolchains//scala:toolchain" +
        version_suffix(SCALA_VERSION)
    ),
)

scala_toolchain(
    name = "unused_dependency_checker_error_toolchain_impl",
    dependency_tracking_method = "ast-plus",
    unused_dependency_checker_mode = "error",
)

scala_toolchain(
    name = "minimal_direct_source_deps_impl",
    dependency_mode = "plus-one",
    dependency_tracking_method = "ast",
    strict_deps_mode = "error",
    unused_dependency_checker_mode = "error",
)

[
    toolchain(
        name = tc,
        toolchain = tc + "_impl",
        toolchain_type = "//scala:toolchain_type",
        visibility = ["//visibility:public"],
    )
    for tc in [
        "unused_dependency_checker_error_toolchain",
        "minimal_direct_source_deps",
    ]
]

java_import(
    name = "bazel_test_runner_deploy",
    jars = ["@bazel_tools//tools/jdk:TestRunner_deploy.jar"],
    visibility = ["//visibility:public"],
)

java_library(
    name = "PlaceHolderClassToCreateEmptyJarForScalaImport",
    srcs = ["PlaceHolderClassToCreateEmptyJarForScalaImport.java"],
    visibility = ["//visibility:public"],
)
