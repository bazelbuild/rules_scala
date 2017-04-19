load("//scala:scala.bzl", "scala_library")

scala_library(
    name = "test_reporter",
    srcs = ["JUnitXmlReporter.scala"],
    visibility = ["//visibility:public"],
    deps = [
        '//external:io_bazel_rules_scala/dependency/scala/scala_xml',
        '//external:io_bazel_rules_scala/dependency/scalatest/scalatest'
    ],
)
