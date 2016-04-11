load("//scala:scala.bzl", "scala_binary")

scala_binary(
  name = "generator",
  srcs = ["TwitterScroogeGenerator.scala"],
  main_class = "scripts.ScroogeGenerator",
  deps = [
    "@scrooge_generator//jar",
    "@util_core//jar",
    "@util_logging//jar",
    ":scala_parsers",
  ],
  visibility = ["//visibility:public"],
)

java_import(
  name = "scala_parsers",
  jars = ["@scala//:lib/scala-parser-combinators_2.11-1.0.4.jar"],
)