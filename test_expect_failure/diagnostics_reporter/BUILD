load("//scala:scala.bzl", "scala_library")
load("//scala:scala_toolchain.bzl", "scala_toolchain")
load("//scala:scala_cross_version_select.bzl", "select_for_scala_version")

scala_toolchain(
    name = "diagnostics_reporter_toolchain_impl",
    enable_diagnostics_report = True,
    visibility = ["//visibility:public"],
)

toolchain(
    name = "diagnostics_reporter_toolchain",
    toolchain = "diagnostics_reporter_toolchain_impl",
    toolchain_type = "//scala:toolchain_type",
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
    toolchain_type = "//scala:toolchain_type",
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
    scalacopts = select_for_scala_version(
        any_2 = ["-Ywarn-unused:imports"],
        any_3 = ["-Wunused:imports"],
    ),
    visibility = ["//visibility:public"],
)

scala_library(
    name = "error_and_warning_file",
    srcs = ["ErrorAndWarningFile.scala"],
    # Warning: Scala 3 supports -Wunused:imports since Scala 3.3
    scalacopts = select_for_scala_version(
        any_2 = ["-Ywarn-unused:imports"],
        any_3 = ["-Wunused:imports"],
    ),
    visibility = ["//visibility:public"],
)

scala_library(
    name = "info_file",
    srcs = ["InfoFile.scala"],
    # Scala 3 uses absolute paths (which might change) when listing operations of files
    # We're using a stable output from genBCode phase instead
    scalacopts = select_for_scala_version(
        any_2 = ["-Ydebug"],
        any_3 = [
            "-Ylog:genBCode",
            "--verbose",
        ],
    ),
    visibility = ["//visibility:public"],
)
