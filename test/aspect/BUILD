load(":aspect.bzl", "aspect_test")
load(
    "//scala:scala.bzl",
    "scala_library",
    "scala_test",
    "scala_junit_test",
    "scala_specs2_junit_test",
)

aspect_test(
    name = "aspect_test",
    targets = [
        ":scala_library",
        ":scala_test",
        ":scala_junit_test",
        ":scala_specs2_junit_test",
    ],
)

scala_library(name = "scala_library")

scala_test(name = "scala_test")

scala_junit_test(
    name = "scala_junit_test",
    srcs = ["FakeJunitTest.scala"],
    suffixes = ["Test"],
)

scala_specs2_junit_test(
    name = "scala_specs2_junit_test",
    srcs = ["FakeJunitTest.scala"],
    suffixes = ["Test"],
)
