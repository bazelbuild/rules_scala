package(default_visibility = ["//bazel_test_runner:__subpackages__"])

# TODO(bazel-team): This should be testonly = 1.
java_library(
    name = "api",
    srcs = glob(["*.java"]),
    deps = [
        "@io_bazel_rules_scala_junit_junit//jar",
    ],
)

filegroup(
    name = "srcs",
    testonly = 0,  # All srcs should be not test only, overwrite package default.
    srcs = glob(["**"]),
)
