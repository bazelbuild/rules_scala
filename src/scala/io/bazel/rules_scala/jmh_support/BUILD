load("//scala:scala.bzl", "scala_binary", "scala_library")

scala_library(
    name = "benchmark_generator_lib",
    srcs = ["BenchmarkGenerator.scala"],
    visibility = ["//visibility:public"],
    deps = [
        "//external:io_bazel_rules_scala/dependency/jmh/jmh_core",
        "//external:io_bazel_rules_scala/dependency/jmh/jmh_generator_asm",
        "//external:io_bazel_rules_scala/dependency/jmh/jmh_generator_reflection",
        "//src/java/io/bazel/rulesscala/jar",
    ],
)

scala_binary(
    name = "benchmark_generator",
    main_class = "io.bazel.rules_scala.jmh_support.BenchmarkGenerator",
    visibility = ["//visibility:public"],
    deps = [":benchmark_generator_lib"],
)
