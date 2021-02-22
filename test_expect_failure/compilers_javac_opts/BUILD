load("//scala:scala.bzl", "scala_library")
load("@bazel_tools//tools/jdk:default_java_toolchain.bzl", "default_java_toolchain")

scala_library(
    name = "can_configure_jvm_flags_for_javac_via_javacopts",
    srcs = ["WillNotCompileSinceJavaToolchainAddsAnInvalidJvmFlag.java"],
)

default_java_toolchain(
    name = "a_java_toolchain",
    javacopts = ["-InvalidFlag"],
    visibility = ["//visibility:public"],
)
