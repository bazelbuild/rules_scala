load(":aspect.bzl", "aspect_testscript")
load(
    "//scala:scala.bzl",
    "scala_junit_test",
    "scala_library",
    "scala_specs2_junit_test",
    "scala_test",
)

aspect_testscript(
    name = "aspect_testscript",
    testonly = True,
    targets = [
        ":scala_library",
        ":scala_test",
        ":scala_junit_test",
        ":scala_specs2_junit_test",
    ],
)

sh_test(
    name = "aspect_test",
    testonly = True,
    srcs = ["aspect_testscript"],
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
