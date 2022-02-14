load("@rules_java//java:defs.bzl", "java_import", "java_library")
load("//scala:scala_toolchain.bzl", "scala_toolchain")
load("//scala:providers.bzl", "declare_deps_provider")
load("@io_bazel_rules_scala_config//:config.bzl", "SCALA_MAJOR_VERSION")

toolchain_type(
    name = "toolchain_type",
    visibility = ["//visibility:public"],
)

scala_toolchain(
    name = "default_toolchain_impl",
    scalacopts = [],
    visibility = ["//visibility:public"],
)

toolchain(
    name = "default_toolchain",
    toolchain = ":default_toolchain_impl",
    toolchain_type = "@io_bazel_rules_scala//scala:toolchain_type",
    visibility = ["//visibility:public"],
)

scala_toolchain(
    name = "unused_dependency_checker_error_toolchain_impl",
    unused_dependency_checker_mode = "error",
    visibility = ["//visibility:public"],
)

toolchain(
    name = "unused_dependency_checker_error_toolchain",
    toolchain = ":unused_dependency_checker_error_toolchain_impl",
    toolchain_type = "@io_bazel_rules_scala//scala:toolchain_type",
    visibility = ["//visibility:public"],
)

scala_toolchain(
    name = "ast_plus_one_deps_strict_deps_unused_deps_error_impl",
    dependency_mode = "plus-one",
    dependency_tracking_method = "ast",
    strict_deps_mode = "error",
    unused_dependency_checker_mode = "error",
    visibility = ["//visibility:public"],
)

toolchain(
    name = "minimal_direct_source_deps",
    toolchain = "ast_plus_one_deps_strict_deps_unused_deps_error_impl",
    toolchain_type = "@io_bazel_rules_scala//scala:toolchain_type",
    visibility = ["//visibility:public"],
)

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

declare_deps_provider(
    name = "scala_compile_classpath_provider",
    deps_id = "scala_compile_classpath",
    visibility = ["//visibility:public"],
    deps = [
        "@io_bazel_rules_scala_scala_compiler",
        "@io_bazel_rules_scala_scala_library",
    ] + (["@io_bazel_rules_scala_scala_reflect"] if SCALA_MAJOR_VERSION.startswith("2") else [
        "@io_bazel_rules_scala_scala_interfaces",
        "@io_bazel_rules_scala_scala_tasty_core",
        "@io_bazel_rules_scala_scala_asm",
        "@io_bazel_rules_scala_scala_library_2",
    ]),
)

declare_deps_provider(
    name = "scala_library_classpath_provider",
    deps_id = "scala_library_classpath",
    visibility = ["//visibility:public"],
    deps = [
        "@io_bazel_rules_scala_scala_library",
    ] + (["@io_bazel_rules_scala_scala_reflect"] if SCALA_MAJOR_VERSION.startswith("2") else [
        "@io_bazel_rules_scala_scala_library_2",
    ]),
)

declare_deps_provider(
    name = "scala_macro_classpath_provider",
    deps_id = "scala_macro_classpath",
    visibility = ["//visibility:public"],
    deps = [
        "@io_bazel_rules_scala_scala_library",
    ] + (["@io_bazel_rules_scala_scala_reflect"] if SCALA_MAJOR_VERSION.startswith("2") else [
        "@io_bazel_rules_scala_scala_library_2",
    ]),
)

declare_deps_provider(
    name = "scala_xml_provider",
    deps_id = "scala_xml",
    visibility = ["//visibility:public"],
    deps = ["@io_bazel_rules_scala_scala_xml"],
)

declare_deps_provider(
    name = "parser_combinators_provider",
    deps_id = "parser_combinators",
    visibility = ["//visibility:public"],
    deps = ["@io_bazel_rules_scala_scala_parser_combinators"],
)
