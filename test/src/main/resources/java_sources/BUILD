load("//scala:scala.bzl", "scala_library")

package(default_visibility = ["//visibility:public"])

scala_library(
    name = "CompiledWithJava8",
    srcs = ["SimpleJavaSourceFileA.java"],
    java_compile_toolchain = "@bazel_tools//tools/jdk:toolchain_java8",
)

scala_library(
    name = "CompiledWithJava11",
    srcs = ["SimpleJavaSourceFileB.java"],
    java_compile_toolchain = "@bazel_tools//tools/jdk:toolchain_java11",
)
