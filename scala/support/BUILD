load("//scala:scala.bzl", "scala_library")


scala_library(name = "test_reporter",
  srcs = ["JUnitXmlReporter.scala"],
  deps = ["@scalatest//file", "//src/scala:scala_xml"],
  visibility = ["//visibility:public"],
  )
