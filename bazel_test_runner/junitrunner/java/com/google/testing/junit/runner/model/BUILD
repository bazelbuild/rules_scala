package(default_visibility = ["//bazel_test_runner:__subpackages__"])

java_library(
    name = "model",
    srcs = glob(["*.java"]),
    deps = [
        "//bazel_test_runner/junitrunner/java/com/google/testing/junit/junit4:runner",
        "//bazel_test_runner/junitrunner/java/com/google/testing/junit/runner/sharding:sharding",
        "//bazel_test_runner/junitrunner/java/com/google/testing/junit/runner/util:util",
        "//external:io_bazel_rules_scala/dependency/javax_annotation_inject/jsr305",
        "//external:io_bazel_rules_scala/dependency/javax/javax_inject",
        "//external:io_bazel_rules_scala/dependency/junit/junit",
    ],
)

filegroup(
    name = "srcs",
    testonly = 0,  # All srcs should be not test only, overwrite package default.
    srcs = glob(["**"]),
)
