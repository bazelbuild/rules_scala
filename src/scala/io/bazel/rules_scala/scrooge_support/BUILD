load("//scala:scala.bzl", "scala_library")

scala_library(
  name = "compiler",
  srcs = ["Compiler.scala"],
  deps = [
    "//external:io_bazel_rules_scala/dependency/thrift/scrooge_generator",
    "//external:io_bazel_rules_scala/dependency/thrift/util_core",
    "//external:io_bazel_rules_scala/dependency/thrift/util_logging",
    "//src/scala:parser_combinators",
    ":focused_zip_importer",
  ],
  visibility = ["//visibility:public"],
)

scala_library(
  name = "focused_zip_importer",
  srcs = ["FocusedZipImporter.scala"],
  deps = [
    "//external:io_bazel_rules_scala/dependency/thrift/scrooge_generator",
  ],
  visibility = ["//visibility:public"],
)

filegroup(
    name = "sources",
    data = glob(["**"]),
    visibility = ["//visibility:public"]
    )