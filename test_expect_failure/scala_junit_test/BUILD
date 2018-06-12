load("//scala:scala.bzl", "scala_junit_test", "scala_specs2_junit_test")

scala_junit_test(
    name = "failing_test",
    size = "small",
    srcs = ["JunitFailureTest.scala"],
    suffixes = ["Test"],
)

scala_junit_test(
    name = "no_prefix_or_suffix",
    size = "small",
    srcs = ["JunitTest.scala"],
)

scala_junit_test(
    name = "no_tests_found",
    size = "small",
    srcs = ["JunitTest.scala"],
    suffixes = ["DoesNotMatch"],
)

scala_specs2_junit_test(
    name = "specs2_failing_test",
    size = "small",
    srcs = ["specs2/FailingTest.scala"],
    suffixes = ["Test"],
)
