load("//scala:scala.bzl", "scala_library")
load("//scala:scala_cross_version_select.bzl", "select_for_scala_version")

licenses(["notice"])  # 3-clause BSD

scala_library(
    name = "test_util",
    srcs = [
        "io/bazel/rulesscala/utils/JavaCompileUtil.scala",
        "io/bazel/rulesscala/utils/TestUtilCommon.scala",
    ] + select_for_scala_version(
        any_2 = [
            "io/bazel/rulesscala/utils/TestUtil.scala",
        ],
        any_3 = [
            "io/bazel/rulesscala/utils/TestUtil3.scala",
        ],
        before_2_13_9 = [
            "io/bazel/rulesscala/utils/CommandLineParserAdapter_before_2_13_9.scala",
        ],
        between_2_13_9_and_3 = [
            "io/bazel/rulesscala/utils/CommandLineParserAdapter_since_2_13_9.scala",
        ],
    ),
    visibility = ["//visibility:public"],
    deps = [
        "//scala/private/toolchain_deps:scala_compile_classpath",
        "//third_party/dependency_analyzer/src/main:dependency_analyzer",
    ],
)
