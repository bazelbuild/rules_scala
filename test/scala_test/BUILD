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
    srcs = ["A.scala", "CustomReporter.scala"],
    reporter_class = "test.scala_test.CustomReporter"
)