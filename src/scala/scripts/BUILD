load("//scala:scala.bzl", "scala_binary", "scala_library")

scala_library(
  name = "generator_lib",
  srcs = ["TwitterScroogeGenerator.scala"],
  deps = [
    "@scrooge_generator//jar",
    "@util_core//jar",
    "@util_logging//jar",
    ":scala_parsers",
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

java_import(
  name = "scala_parsers",
  jars = ["@scala//:lib/scala-parser-combinators_2.11-1.0.4.jar"],
)
