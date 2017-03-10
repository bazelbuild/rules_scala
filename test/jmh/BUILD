load("//jmh:jmh.bzl", "scala_library", "scala_benchmark_jmh")

native.java_library(
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
    deps = [":scala_type", ":java_type"],
    exports = [":scala_type", ":java_type"],
    visibility = ["//visibility:public"],
)

scala_benchmark_jmh(
    name = "test_benchmark",
    srcs = ["TestBenchmark.scala"],
    deps = [":add_numbers"],
)
