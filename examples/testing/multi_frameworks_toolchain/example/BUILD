load("@io_bazel_rules_scala//scala:scala.bzl", "scala_test", "scala_specs2_junit_test")

scala_test(
    name = "scalatest_example",
    srcs = ["ScalaTestExampleTest.scala"],
)

scala_specs2_junit_test(
    name = "specs2_example",
    srcs = ["Specs2ExampleTest.scala"],
    suffixes = ["Test"],
)