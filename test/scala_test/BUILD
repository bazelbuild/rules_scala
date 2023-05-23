load("@io_bazel_rules_scala//scala:scala.bzl", "scala_test")

scala_test(
    name = "a",
    srcs = ["A.scala"],
)

scala_test(
    name = "b",
    srcs = ["B.scala"],
    deps = [":a"],
)

scala_test(
    name = "custom_reporter",
    srcs = [
        "A.scala",
        "CustomReporter.scala",
    ],
    reporter_class = "test.scala_test.CustomReporter",
)

# Check that we can run scala tests in external workspaces.
test_suite(
    name = "external_scala_test",
    tests = [
        "@example_external_workspace//test:empty_test",
    ]
)