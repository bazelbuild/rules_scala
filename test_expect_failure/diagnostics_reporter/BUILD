load("//scala:scala.bzl", "scala_library")
load("//scala:scala_toolchain.bzl", "scala_toolchain")

scala_toolchain(
    name = "diagnostics_reporter_toolchain_impl",
    enable_diagnostics_report = True,
    visibility = ["//visibility:public"],
)

toolchain(
    name = "diagnostics_reporter_toolchain",
    toolchain = "diagnostics_reporter_toolchain_impl",
    toolchain_type = "@io_bazel_rules_scala//scala:toolchain_type",
    visibility = ["//visibility:public"],
)

scala_toolchain(
    name = "diagnostics_reporter_and_semanticdb_toolchain_impl",
    enable_diagnostics_report = True,
    enable_semanticdb = True,
    visibility = ["//visibility:public"],
)

toolchain(
    name = "diagnostics_reporter_and_semanticdb_toolchain",
    toolchain = "diagnostics_reporter_and_semanticdb_toolchain_impl",
    toolchain_type = "@io_bazel_rules_scala//scala:toolchain_type",
    visibility = ["//visibility:public"],
)

scala_library(
    name = "error_file",
    srcs = ["ErrorFile.scala"],
    visibility = ["//visibility:public"],
)

scala_library(
    name = "two_errors_file",
    srcs = ["TwoErrorsFile.scala"],
    visibility = ["//visibility:public"],
)

scala_library(
    name = "warning_file",
    srcs = ["WarningFile.scala"],
    scalacopts = ["-Ywarn-unused:imports"],
    visibility = ["//visibility:public"],
)

scala_library(
    name = "error_and_warning_file",
    srcs = ["ErrorAndWarningFile.scala"],
    scalacopts = ["-Ywarn-unused:imports"],
    visibility = ["//visibility:public"],
)

scala_library(
    name = "info_file",
    srcs = ["InfoFile.scala"],
    scalacopts = ["-Ydebug"],
    visibility = ["//visibility:public"],
)
