load("@rules_java//java:defs.bzl", "java_import", "java_library")
load(
    "@io_bazel_rules_scala//scala:providers.bzl",
    _declare_scalac_provider = "declare_scalac_provider",
)
load("//scala:scala_toolchain.bzl", "scala_toolchain")

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
    name = "ast_plus_one_deps_strict_deps_unused_deps_error",
    toolchain = "ast_plus_one_deps_strict_deps_unused_deps_error_impl",
    toolchain_type = "@io_bazel_rules_scala//scala:toolchain_type",
    visibility = ["//visibility:public"],
)

scala_toolchain(
    name = "code_coverage_toolchain_impl",
    enable_code_coverage_aspect = "on",
    visibility = ["//visibility:public"],
)

toolchain(
    name = "code_coverage_toolchain",
    toolchain = "code_coverage_toolchain_impl",
    toolchain_type = "@io_bazel_rules_scala//scala:toolchain_type",
    visibility = ["//visibility:public"],
)

java_import(
    name = "bazel_test_runner_deploy",
    jars = ["@bazel_tools//tools/jdk:TestRunner_deploy.jar"],
    visibility = ["//visibility:public"],
)

_declare_scalac_provider(
    name = "scalac_default",
    default_classpath = [
        "//external:io_bazel_rules_scala/dependency/scala/scala_library",
        "//external:io_bazel_rules_scala/dependency/scala/scala_reflect",
    ],
    default_macro_classpath = [
        "//external:io_bazel_rules_scala/dependency/scala/scala_library",
        "//external:io_bazel_rules_scala/dependency/scala/scala_reflect",
    ],
    default_repl_classpath = [
        "//external:io_bazel_rules_scala/dependency/scala/scala_library",
        "//external:io_bazel_rules_scala/dependency/scala/scala_reflect",
        "//external:io_bazel_rules_scala/dependency/scala/scala_compiler",
    ],
    visibility = ["//visibility:public"],
)

java_library(
    name = "PlaceHolderClassToCreateEmptyJarForScalaImport",
    srcs = ["PlaceHolderClassToCreateEmptyJarForScalaImport.java"],
    visibility = ["//visibility:public"],
)
