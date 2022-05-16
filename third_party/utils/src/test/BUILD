load("//scala:scala.bzl", "scala_library")
load("@io_bazel_rules_scala_config//:config.bzl", "SCALA_MAJOR_VERSION")

licenses(["notice"])  # 3-clause BSD

scala_library(
    name = "test_util",
    srcs = ([
        "io/bazel/rulesscala/utils/JavaCompileUtil.scala",
        "io/bazel/rulesscala/utils/TestUtil.scala",
    ] if SCALA_MAJOR_VERSION.startswith("2") else [
        "io/bazel/rulesscala/utils/Scala3CompilerUtils.scala",
    ]),
    visibility = ["//visibility:public"],
    deps = ([
        "//scala/private/toolchain_deps:scala_compile_classpath",
        "//third_party/dependency_analyzer/src/main:dependency_analyzer",
    ] if SCALA_MAJOR_VERSION.startswith("2") else [
        "//scala/private/toolchain_deps:scala_compile_classpath",
    ]),
)
