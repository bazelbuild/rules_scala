package(default_visibility = ["//bazel_test_runner:__subpackages__"])

java_library(
    name = "testing",
    testonly = 1,
    srcs = glob(["*.java"]),
    deps = [
        "//bazel_test_runner/junitrunner/java/com/google/testing/junit/runner/sharding:sharding",
        "//bazel_test_runner/junitrunner/java/com/google/testing/junit/runner/sharding/api:api",
        "//third_party:guava",
        "//third_party:junit4",
        "//third_party:truth",
    ],
)

filegroup(
    name = "srcs",
    testonly = 0,  # All srcs should be not test only, overwrite package default.
    srcs = glob(["**"]),
)
