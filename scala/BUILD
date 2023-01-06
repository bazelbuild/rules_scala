load("@rules_java//java:defs.bzl", "java_import", "java_library")
load("//scala:providers.bzl", "declare_deps_provider")
load("//scala:scala.bzl", "setup_scala_toolchain")
load("@io_bazel_rules_scala_config//:config.bzl", "SCALA_MAJOR_VERSION")

toolchain_type(
    name = "toolchain_type",
    visibility = ["//visibility:public"],
)

_SCALA_COMPILE_CLASSPATH_DEPS = [
    "@io_bazel_rules_scala_scala_compiler",
    "@io_bazel_rules_scala_scala_library",
] + (["@io_bazel_rules_scala_scala_reflect"] if SCALA_MAJOR_VERSION.startswith("2") else [
    "@io_bazel_rules_scala_scala_interfaces",
    "@io_bazel_rules_scala_scala_tasty_core",
    "@io_bazel_rules_scala_scala_asm",
    "@io_bazel_rules_scala_scala_library_2",
])

_SCALA_LIBRARY_CLASSPATH_DEPS = [
    "@io_bazel_rules_scala_scala_library",
] + (["@io_bazel_rules_scala_scala_reflect"] if SCALA_MAJOR_VERSION.startswith("2") else [
    "@io_bazel_rules_scala_scala_library_2",
])

_SCALA_MACRO_CLASSPATH_DEPS = [
    "@io_bazel_rules_scala_scala_library",
] + (["@io_bazel_rules_scala_scala_reflect"] if SCALA_MAJOR_VERSION.startswith("2") else [
    "@io_bazel_rules_scala_scala_library_2",
])

_PARSER_COMBINATORS_DEPS = ["@io_bazel_rules_scala_scala_parser_combinators"]

_SCALA_XML_DEPS = ["@io_bazel_rules_scala_scala_xml"]

setup_scala_toolchain(
    name = "default_toolchain",
    scala_compile_classpath = _SCALA_COMPILE_CLASSPATH_DEPS,
    scala_library_classpath = _SCALA_LIBRARY_CLASSPATH_DEPS,
    scala_macro_classpath = _SCALA_MACRO_CLASSPATH_DEPS,
    use_argument_file_in_runner = True,
)

setup_scala_toolchain(
    name = "unused_dependency_checker_error_toolchain",
    dependency_tracking_method = "ast-plus",
    scala_compile_classpath = _SCALA_COMPILE_CLASSPATH_DEPS,
    scala_library_classpath = _SCALA_LIBRARY_CLASSPATH_DEPS,
    scala_macro_classpath = _SCALA_MACRO_CLASSPATH_DEPS,
    unused_dependency_checker_mode = "error",
)

setup_scala_toolchain(
    name = "minimal_direct_source_deps",
    dependency_mode = "plus-one",
    dependency_tracking_method = "ast",
    scala_compile_classpath = _SCALA_COMPILE_CLASSPATH_DEPS,
    scala_library_classpath = _SCALA_LIBRARY_CLASSPATH_DEPS,
    scala_macro_classpath = _SCALA_MACRO_CLASSPATH_DEPS,
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
    deps = _SCALA_COMPILE_CLASSPATH_DEPS,
)

declare_deps_provider(
    name = "scala_library_classpath_provider",
    deps_id = "scala_library_classpath",
    visibility = ["//visibility:public"],
    deps = _SCALA_LIBRARY_CLASSPATH_DEPS,
)

declare_deps_provider(
    name = "scala_macro_classpath_provider",
    deps_id = "scala_macro_classpath",
    visibility = ["//visibility:public"],
    deps = _SCALA_MACRO_CLASSPATH_DEPS,
)

declare_deps_provider(
    name = "scala_xml_provider",
    deps_id = "scala_xml",
    visibility = ["//visibility:public"],
    deps = _SCALA_XML_DEPS,
)

declare_deps_provider(
    name = "parser_combinators_provider",
    deps_id = "parser_combinators",
    visibility = ["//visibility:public"],
    deps = _PARSER_COMBINATORS_DEPS,
)
