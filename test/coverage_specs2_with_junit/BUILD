load("@rules_java//java:defs.bzl", "java_library")
load("//scala:scala.bzl", "scala_library", "scala_specs2_junit_test")

scala_specs2_junit_test(
    name = "test-specs2-with-junit",
    size = "medium",
    srcs = ["TestWithSpecs2WithJUnit.scala"],
    prefixes = ["Test"],
    deps = [
        ":a1",
        ":a2",
        ":b1",
        ":d1",
        ":e1",
    ],
)

scala_library(
    name = "a1",
    srcs = [
        "A1.scala",
    ],
    deps = [
        ":b1",
    ],
)

scala_library(
    name = "b1",
    srcs = [
        "B1.scala",
    ],
)

scala_library(
    name = "a2",
    srcs = [
        "A2.scala",
    ],
    deps = [
        ":b2",
    ],
)

java_library(
    name = "b2",
    srcs = [
        "B2.java",
    ],
    deps = [
        ":c2",
    ],
)

scala_library(
    name = "c2",
    srcs = [
        "C2.scala",
    ],
)

scala_library(
    name = "d1",
    srcs = [
        "D1.scala",
    ],
)

scala_library(
    name = "e1",
    srcs = [
        "A1.scala",
        "D1.scala",
        "E1.scala",
    ],
    deps = [
        ":b1",
    ],
)
