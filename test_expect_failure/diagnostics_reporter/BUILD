load("//scala:scala.bzl", "scala_library")

scala_library(
    name = "simple_file",
    srcs = ["SimpleFile.scala"],
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
    scalacopts =["-Ywarn-unused:imports"],
    visibility = ["//visibility:public"],
)

scala_library(
    name = "error_and_warning_file",
    srcs = ["ErrorAndWarningFile.scala"],
    scalacopts =["-Ywarn-unused:imports"],
    visibility = ["//visibility:public"],
)

scala_library(
    name = "info_file",
    srcs = ["InfoFile.scala"],
    scalacopts =["-Ydebug"],
    visibility = ["//visibility:public"],
)