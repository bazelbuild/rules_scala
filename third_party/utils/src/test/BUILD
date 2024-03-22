load("//scala:scala.bzl", "scala_library")
load("//scala:scala_cross_version_select.bzl", "select_for_scala_version")

licenses(["notice"])  # 3-clause BSD

scala_library(
    name = "test_util",
    srcs = select_for_scala_version(
        any_2 = [
            "io/bazel/rulesscala/utils/JavaCompileUtil.scala",
            "io/bazel/rulesscala/utils/TestUtil.scala",
        ],
        any_3 = [
            "io/bazel/rulesscala/utils/Scala3CompilerUtils.scala",
        ],
    ),
    visibility = ["//visibility:public"],
    deps = [
        "//scala/private/toolchain_deps:scala_compile_classpath",
        "//third_party/dependency_analyzer/src/main:dependency_analyzer",
    ],
)
