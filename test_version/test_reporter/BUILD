load("@rules_scala//scala:scala.bzl", "scala_library")
load("@rules_scala//scala:scala_toolchain.bzl", "scala_toolchain")

scala_toolchain(
    name = "diagnostics_reporter_toolchain_impl",
    enable_diagnostics_report = True,
    visibility = ["//visibility:public"],
)

toolchain(
    name = "diagnostics_reporter_toolchain",
    toolchain = "diagnostics_reporter_toolchain_impl",
    toolchain_type = "@rules_scala//scala:toolchain_type",
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
    toolchain_type = "@rules_scala//scala:toolchain_type",
    visibility = ["//visibility:public"],
)

scala_toolchain(
    name = "no_diagnostics_reporter_toolchain_impl",
    visibility = ["//visibility:public"],
)

toolchain(
    name = "no_diagnostics_reporter_toolchain",
    toolchain = "no_diagnostics_reporter_toolchain_impl",
    toolchain_type = "@rules_scala//scala:toolchain_type",
    visibility = ["//visibility:public"],
)

scala_library(
    name = "error_file",
    srcs = ["ErrorFile.scala"],
    visibility = ["//visibility:public"],
)
