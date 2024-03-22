load("@rules_java//java:defs.bzl", "java_import", "java_library")
load("//scala:providers.bzl", "declare_deps_provider")
load("//scala:scala_cross_version.bzl", "version_suffix")
load("//scala/private:macros/setup_scala_toolchain.bzl", "default_deps", "setup_scala_toolchain")
load("@io_bazel_rules_scala_config//:config.bzl", "SCALA_VERSION", "SCALA_VERSIONS")

toolchain_type(
    name = "toolchain_type",
    visibility = ["//visibility:public"],
)

[
    setup_scala_toolchain(
        name = "toolchain" + version_suffix(scala_version),
        scala_version = scala_version,
        use_argument_file_in_runner = True,
    )
    for scala_version in SCALA_VERSIONS
]

# Alias for backward compatibility
alias(
    name = "default_toolchain",
    actual = "toolchain" + version_suffix(SCALA_VERSION),
)

setup_scala_toolchain(
    name = "unused_dependency_checker_error_toolchain",
    dependency_tracking_method = "ast-plus",
    unused_dependency_checker_mode = "error",
)

setup_scala_toolchain(
    name = "minimal_direct_source_deps",
    dependency_mode = "plus-one",
    dependency_tracking_method = "ast",
    strict_deps_mode = "error",
    unused_dependency_checker_mode = "error",
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
    deps = default_deps("scala_compile_classpath", SCALA_VERSION),
)

declare_deps_provider(
    name = "scala_library_classpath_provider",
    deps_id = "scala_library_classpath",
    visibility = ["//visibility:public"],
    deps = default_deps("scala_library_classpath", SCALA_VERSION),
)

declare_deps_provider(
    name = "scala_macro_classpath_provider",
    deps_id = "scala_macro_classpath",
    visibility = ["//visibility:public"],
    deps = default_deps("scala_macro_classpath", SCALA_VERSION),
)

declare_deps_provider(
    name = "scala_xml_provider",
    deps_id = "scala_xml",
    visibility = ["//visibility:public"],
    deps = default_deps("scala_xml", SCALA_VERSION),
)

declare_deps_provider(
    name = "parser_combinators_provider",
    deps_id = "parser_combinators",
    visibility = ["//visibility:public"],
    deps = default_deps("parser_combinators", SCALA_VERSION),
)

declare_deps_provider(
    name = "semanticdb_provider",
    deps_id = "semanticdb",
    visibility = ["//visibility:public"],
    deps = default_deps("semanticdb", SCALA_VERSION),
)
