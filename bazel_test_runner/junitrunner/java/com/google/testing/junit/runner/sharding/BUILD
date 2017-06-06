package(default_visibility = ["//bazel_test_runner:__subpackages__"])

# TODO(bazel-team): This should be testonly = 1.
java_library(
    name = "sharding",
    srcs = glob(["*.java"]),
    deps = [
        "//bazel_test_runner/junitrunner/java/com/google/testing/junit/runner/sharding/api:api",
        "//bazel_test_runner/junitrunner/java/com/google/testing/junit/runner/util:util",
        "@javax_annotation_inject//jar",
        "@javax_inject//jar",
        "@io_bazel_rules_scala_junit_junit//jar",
    ],
)

filegroup(
    name = "srcs",
    testonly = 0,  # All srcs should be not test only, overwrite package default.
    srcs = glob(["**"]),
)
