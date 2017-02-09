load("//scala:scala.bzl", "scala_binary", "scala_library")

scala_library(
  name = "generator_lib",
  srcs = ["TwitterScroogeGenerator.scala"],
  deps = [
    "@scrooge_generator//jar",
    "@util_core//jar",
    "@util_logging//jar",
    "//src/scala/io/bazel/rules_scala/scrooge_support:compiler",
    "//src/scala:parser_combinators",
    "//src/java/io/bazel/rulesscala/jar",
  ],
  visibility = ["//visibility:public"],
)

scala_binary(
  name = "generator",
  main_class = "scripts.ScroogeGenerator",
  deps = [
    ":generator_lib",
  ],
  visibility = ["//visibility:public"],
)
