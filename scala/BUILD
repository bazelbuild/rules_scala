load("@rules_java//java:defs.bzl", "java_import", "java_library")
load("//scala:scala.bzl", "declare_dep_providers", "setup_scala_toolchains")

toolchain_type(
    name = "toolchain_type",
    visibility = ["//visibility:public"],
)

setup_scala_toolchains()

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

declare_dep_providers()
