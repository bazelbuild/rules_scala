load("@rules_java//java:defs.bzl", "java_library", "java_test")
load("//scala:scala.bzl", "scala_library", "scala_test")

scala_test(
    name = "test-all",
    srcs = [
        "TestAll.scala",
    ],
    deps = [
        ":a1",
        ":a2",
        ":b1",
        ":d1",
    ],
)

java_test(
    name = "test-b2",
    srcs = [
        "TestB2.java",
    ],
    tags = ["manual"],
    test_class = "coverage.TestB2",
    deps = [
        ":b2",
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
