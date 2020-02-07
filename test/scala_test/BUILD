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
