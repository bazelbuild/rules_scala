# Description:
#
#   JUnit 4.x extensions

package(
    default_testonly = 1,
    default_visibility = ["//bazel_test_runner:__subpackages__"],
)

# Libraries
# =========================================================

# Extensions for writing custom JUnit4 runners
java_library(
    name = "runner",
    testonly = 0,  # TODO(bazel-team): make it testonly
    srcs = glob(["runner/*.java"]),
    deps = [
        "//external:io_bazel_rules_scala/dependency/javax/javax_inject",
        "//external:io_bazel_rules_scala/dependency/junit/junit",
    ],
)

filegroup(
    name = "srcs",
    testonly = 0,  # All srcs should be not test only, overwrite package default.
    srcs = glob(["**"]),
)
