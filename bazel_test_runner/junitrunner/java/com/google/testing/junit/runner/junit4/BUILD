package(default_visibility = ["//bazel_test_runner:__subpackages__"])

# JUnit4 test runner core code.
java_library(
    name = "junit4",
    srcs = glob(["*.java"]),
    deps = [
        "//bazel_test_runner/junitrunner/java/com/google/testing/junit/junit4:runner",
        "//bazel_test_runner/junitrunner/java/com/google/testing/junit/runner/internal:internal",
        "//bazel_test_runner/junitrunner/java/com/google/testing/junit/runner/internal:junit4",
        "//bazel_test_runner/junitrunner/java/com/google/testing/junit/runner/model:model",
        "//bazel_test_runner/junitrunner/java/com/google/testing/junit/runner/sharding:sharding",
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
