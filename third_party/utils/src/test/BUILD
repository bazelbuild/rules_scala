load("//scala:scala.bzl", "scala_library")

licenses(["notice"])  # 3-clause BSD

scala_library(
    name = "test_util",
    srcs = [
        "io/bazel/rulesscala/utils/JavaCompileUtil.scala",
        "io/bazel/rulesscala/utils/TestUtil.scala",
    ],
    visibility = ["//visibility:public"],
    deps = [
        "//scala/private/toolchain_deps:scala_compile_classpath",
        "//third_party/dependency_analyzer/src/main:dependency_analyzer",
    ],
)
