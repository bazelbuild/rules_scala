package(default_visibility = ["//visibility:public"])

filegroup(
    name = "common_runner_java_files",
    srcs = glob(
        ["*.java"],
        exclude =
            [
                "BazelTestRunner.java",
            ],
    ),
)

java_library(
    name = "test_runner",
    srcs = [
        "BazelTestRunner.java",
        ":common_runner_java_files",
    ],
    data = ["//bazel_test_runner/tools:test_sharding_compliant"],
    deps = [
        "//bazel_test_runner/junitrunner/java/com/google/testing/junit/runner/internal:internal",
        "//bazel_test_runner/junitrunner/java/com/google/testing/junit/runner/junit4:junit4",
        "//bazel_test_runner/junitrunner/java/com/google/testing/junit/runner/model:model",
        "//bazel_test_runner/junitrunner/java/com/google/testing/junit/runner/sharding:sharding",
        "//bazel_test_runner/junitrunner/java/com/google/testing/junit/runner/util:util",
        "//external:io_bazel_rules_scala/dependency/junit/junit",
    ],
)

java_binary(
    name = "Runner",
    main_class = "com.google.testing.junit.runner.BazelTestRunner",
    runtime_deps = [":test_runner"],
)

filegroup(
    name = "srcs",
    testonly = 0,  # All srcs should be not test only, overwrite package default.
    srcs = glob(["**"]),
)
