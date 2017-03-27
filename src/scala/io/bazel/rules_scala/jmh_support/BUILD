load("//scala:scala.bzl", "scala_binary", "scala_library")

scala_library(
  name = "benchmark_generator_lib",
  srcs = ["BenchmarkGenerator.scala"],
  deps = [
      "//external:io_bazel_rules_scala/dependency/jmh/jmh_core",
      "//external:io_bazel_rules_scala/dependency/jmh/jmh_generator_asm",
      "//external:io_bazel_rules_scala/dependency/jmh/jmh_generator_reflection",
      "//external:io_bazel_rules_scala/dependency/jmh/org_ows2_asm_asm",      
      "//src/scala:scala_compiler",
      "//src/java/io/bazel/rulesscala/io_utils",
      "//src/java/io/bazel/rulesscala/jar",
  ],
  visibility = ["//visibility:public"],
)

scala_binary(
  name = "benchmark_generator",
  main_class = "io.bazel.rules_scala.jmh_support.BenchmarkGenerator",
  deps = [":benchmark_generator_lib"],
  visibility = ["//visibility:public"],
)
