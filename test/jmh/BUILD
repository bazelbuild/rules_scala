load("@rules_java//java:defs.bzl", "java_library")
load("//scala:scala.bzl", "scala_library", "scala_test")
load("//jmh:jmh.bzl", "scala_benchmark_jmh")

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

scala_library(
    name = "add_numbers_testonly",
    testonly = True,
    srcs = ["AddNumbers.scala"],
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
    data = ["data.txt"],
    deps = [":add_numbers"],
)

scala_benchmark_jmh(
    name = "test_benchmark_testonly",
    testonly = True,
    srcs = ["TestBenchmark.scala"],
    data = ["data.txt"],
    deps = [":add_numbers_testonly"],
)

scala_test(
    name = "jmh_command_line_parsing_test",
    args = ["-h"],
    main_class = "org.openjdk.jmh.Main",
    deps = [":test_benchmark"],
)
