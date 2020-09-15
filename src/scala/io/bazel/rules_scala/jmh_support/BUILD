load("//scala:scala.bzl", "scala_binary", "scala_library")

scala_library(
    name = "benchmark_generator_lib",
    srcs = ["BenchmarkGenerator.scala"],
    visibility = ["//visibility:public"],
    runtime_deps = [
        "//jmh:benchmark_generator_runtime",
    ],
    deps = [
        "//jmh:benchmark_generator",
    ],
)

scala_binary(
    name = "benchmark_generator",
    main_class = "io.bazel.rules_scala.jmh_support.BenchmarkGenerator",
    visibility = ["//visibility:public"],
    deps = [":benchmark_generator_lib"],
)
