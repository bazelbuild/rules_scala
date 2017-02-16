load("//scala:scala.bzl", "scala_binary", "scala_library")

scala_library(
  name = "generator_lib",
  srcs = ["TwitterScroogeGenerator.scala"],
  deps = [
    "//external:io_bazel_rules_scala/dependency/thrift/scrooge_generator",
    "//external:io_bazel_rules_scala/dependency/thrift/util_core",
    "//external:io_bazel_rules_scala/dependency/thrift/util_logging",
    "//src/scala/io/bazel/rules_scala/scrooge_support:compiler",
    "//src/scala:parser_combinators",
    "//src/java/io/bazel/rulesscala/jar",
    "//src/java/io/bazel/rulesscala/worker",
  ],
  visibility = ["//visibility:public"],
)

scala_binary(
  name = "generator",
  main_class = "scripts.ScroogeWorker",
  deps = [
    ":generator_lib",
  ],
  visibility = ["//visibility:public"],
)
