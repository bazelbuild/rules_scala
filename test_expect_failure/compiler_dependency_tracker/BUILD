load("//scala:scala_toolchain.bzl", "scala_toolchain")
load("@io_bazel_rules_scala//scala:scala.bzl", "scala_library")

scala_toolchain(
    name = "ast_plus_error_impl",
    compiler_deps_mode = "error",
    dependency_mode = "plus-one",
    dependency_tracking_method = "ast-plus",
    strict_deps_mode = "error",
    unused_dependency_checker_mode = "error",
    visibility = ["//visibility:public"],
)

toolchain(
    name = "ast_plus_error",
    toolchain = ":ast_plus_error_impl",
    toolchain_type = "@io_bazel_rules_scala//scala:toolchain_type",
    visibility = ["//visibility:public"],
)

scala_library(
    name = "unused_dep",
    srcs = ["A.scala"],
    deps = [":E"],
)

scala_library(
    name = "missing_compile_dep",
    srcs = ["B.scala"],
    deps = [":D"],
)

scala_library(
    name = "missing_source_dep",
    srcs = ["C.scala"],
    deps = [":D"],
)

scala_library(
    name = "B",
    srcs = ["B.scala"],
    deps = [":D"],
)

scala_library(
    name = "D",
    srcs = ["D.scala"],
    deps = [":E"],
)

scala_library(
    name = "E",
    srcs = ["E.scala"],
)
