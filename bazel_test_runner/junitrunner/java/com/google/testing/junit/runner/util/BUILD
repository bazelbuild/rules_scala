package(default_visibility = ["//bazel_test_runner:__subpackages__"])

java_library(
    name = "util",
    srcs = glob(["*.java"]),
    deps = [
        "@javax_annotation_inject//jar",
        "@io_bazel_rules_scala_junit_junit//jar",
    ],
)

filegroup(
    name = "srcs",
    testonly = 0,  # All srcs should be not test only, overwrite package default.
    srcs = glob(["**"]),
)
