package(default_visibility = ["//bazel_test_runner:__subpackages__"])

# Internal code for the JUnit runner that does not depend on JUnit 4.
# Code used by the JUnit runner that does depend on JUnit 4
# lives in the ":junit4" rule.
java_library(
    name = "internal",
    srcs = glob(["*.java"]),
    deps = [
        "//bazel_test_runner/junitrunner/java/com/google/testing/junit/runner/util:util",
        "//external:io_bazel_rules_scala/dependency/javax/javax_inject",
    ],
)

# Internal code for the JUnit runner that depends on JUnit 4.
# Code used by the JUnit runner that doesn't depend on JUnit 4
# lives in the "internal" rule.
java_library(
    name = "junit4",
    srcs = glob(["junit4/*.java"]),
    deps = [
        ":internal",
        "//bazel_test_runner/junitrunner/java/com/google/testing/junit/junit4:runner",
        "//bazel_test_runner/junitrunner/java/com/google/testing/junit/runner/model:model",
        "//bazel_test_runner/junitrunner/java/com/google/testing/junit/runner/util:util",
        "//external:io_bazel_rules_scala/dependency/javax/javax_inject",
        "//external:io_bazel_rules_scala/dependency/junit/junit",
    ],
)

filegroup(
    name = "srcs",
    testonly = 0,  # All srcs should be not test only, overwrite package default.
    srcs = glob(["**"]),
)
