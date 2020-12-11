load("@io_bazel_rules_scala//scala:scala.bzl", "scala_test")
load(
    "//test/scala_test:custom_scala_test.bzl",
    "custom_default_attrs_scala_test",
)

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

custom_default_attrs_scala_test(
    name = "custom_reporter_with_default_attrs",
    srcs = [
        "A.scala",
        "CustomReporter.scala",
    ],
)
