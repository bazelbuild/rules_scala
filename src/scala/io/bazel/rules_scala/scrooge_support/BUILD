load("//scala:scala.bzl", "scala_library")

scala_library(
  name = "compiler",
  srcs = ["Compiler.scala"],
  deps = [
    "@scrooge_generator//jar",
    "@util_core//jar",
    "@util_logging//jar",
    "//src/scala:parser_combinators",
    ":focused_zip_importer",
  ],
  visibility = ["//visibility:public"],
)

scala_library(
  name = "focused_zip_importer",
  srcs = ["FocusedZipImporter.scala"],
  deps = [
    "@scrooge_generator//jar",
  ],
  visibility = ["//visibility:public"],
)
