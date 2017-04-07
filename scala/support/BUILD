load("//scala:scala.bzl", "scala_library")

scala_library(
    name = "test_reporter",
    srcs = ["JUnitXmlReporter.scala"],
    visibility = ["//visibility:public"],
    deps = [
        "//src/scala:scala_xml",
        "@scalatest//jar",
    ],
)
