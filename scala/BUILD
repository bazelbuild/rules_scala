load("//scala:bootstrap_toolchain.bzl", "bootstrap_toolchain")
load("//scala:scala_toolchain.bzl", "scala_toolchain")
load("//scala:scala_test_toolchain.bzl", "scala_test_toolchain")

# default toolchains registered by `scala_register_toolchains`

# bootstrap toolchain

toolchain_type(
    name = "bootstrap_toolchain_type",
    visibility = ["//visibility:public"],
)

bootstrap_toolchain(
    name = "bootstrap_toolchain_impl",
    classpath = [
        "@io_bazel_rules_scala_scala_library",
        "@io_bazel_rules_scala_scala_reflect",
    ],
    macro_classpath = [
        "@io_bazel_rules_scala_scala_library",
        "@io_bazel_rules_scala_scala_reflect",
    ],
    repl_classpath = [
        "@io_bazel_rules_scala_scala_library",
        "@io_bazel_rules_scala_scala_reflect",
        "@io_bazel_rules_scala_scala_compiler",
    ],
    visibility = ["//visibility:public"],
)

toolchain(
    name = "bootstrap_toolchain",
    toolchain = ":bootstrap_toolchain_impl",
    toolchain_type = "@io_bazel_rules_scala//scala:bootstrap_toolchain_type",
    visibility = ["//visibility:public"],
)

# standard toolchain

toolchain_type(
    name = "toolchain_type",
    visibility = ["//visibility:public"],
)

scala_toolchain(
    name = "toolchain_impl",
    scalac = "//src/java/io/bazel/rulesscala/scalac",
    scalacopts = [],
    visibility = ["//visibility:public"],
)

toolchain(
    name = "toolchain",
    toolchain = ":toolchain_impl",
    toolchain_type = "@io_bazel_rules_scala//scala:toolchain_type",
    visibility = ["//visibility:public"],
)

# test toolchain

toolchain_type(
    name = "scala_test_toolchain_type",
    visibility = ["//visibility:public"],
)

scala_test_toolchain(
    name = "scala_test_toolchain_impl",
    reporter = "//scala/support:test_reporter",
    runner = "//src/java/io/bazel/rulesscala/scala_test:runner",
    visibility = ["//visibility:public"],
    deps = [
        "//external:io_bazel_rules_scala/dependency/scalatest/scalatest",
    ],
)

toolchain(
    name = "scala_test_toolchain",
    toolchain = ":scala_test_toolchain_impl",
    toolchain_type = "@io_bazel_rules_scala//scala:scala_test_toolchain_type",
    visibility = ["//visibility:public"],
)

# unused dependency checker toolchain

scala_toolchain(
    name = "unused_dependency_checker_error_toolchain_impl",
    scalac = "//src/java/io/bazel/rulesscala/scalac",
    unused_dependency_checker_mode = "error",
    visibility = ["//visibility:public"],
)

toolchain(
    name = "unused_dependency_checker_error_toolchain",
    toolchain = ":unused_dependency_checker_error_toolchain_impl",
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
