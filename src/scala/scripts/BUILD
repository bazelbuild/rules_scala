load("//scala:scala.bzl", "scala_binary", "scala_library")

scala_library(
    name = "generator_lib",
    srcs = ["TwitterScroogeGenerator.scala"],
    visibility = ["//visibility:public"],
    deps = [
        "//external:io_bazel_rules_scala/dependency/thrift/scrooge_generator",
        "//external:io_bazel_rules_scala/dependency/thrift/util_core",
        "//external:io_bazel_rules_scala/dependency/thrift/util_logging",
        "//src/java/io/bazel/rulesscala/io_utils",
        "//src/java/io/bazel/rulesscala/jar",
        "//src/java/io/bazel/rulesscala/worker",
        "//src/scala/io/bazel/rules_scala/scrooge_support:compiler",
        "@scala//:scala-parser-combinators",
    ],
)

scala_binary(
    name = "generator",
    main_class = "scripts.ScroogeWorker",
    visibility = ["//visibility:public"],
    deps = [
        ":generator_lib",
    ],
)
