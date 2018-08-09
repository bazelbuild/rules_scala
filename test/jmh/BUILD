load("//jmh:jmh.bzl", "scala_library", "scala_benchmark_jmh")

java_library(
    name = "java_type",
    srcs = ["JavaType.java"],
    visibility = ["//visibility:public"],
)

scala_library(
    name = "scala_type",
    srcs = ["ScalaType.scala"],
    visibility = ["//visibility:public"],
)

scala_library(
    name = "add_numbers",
    srcs = ["AddNumbers.scala"],
    unused_dependency_checker_mode = "off",
    visibility = ["//visibility:public"],
    exports = [
        ":java_type",
        ":scala_type",
    ],
    deps = [
        ":java_type",
        ":scala_type",
    ],
)

scala_benchmark_jmh(
    name = "test_benchmark",
    srcs = ["TestBenchmark.scala"],
    deps = [":add_numbers"],
)
