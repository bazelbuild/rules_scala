load("//scala:scala.bzl", "scala_library")


java_import(
    name = "scala_xml",
    jars = ["@scala//:lib/scala-xml_2.11-1.0.4.jar"]
)

scala_library(name = "test_reporter",
  srcs = ["JUnitXmlReporter.scala"],
  deps = ["@scalatest//file", ":scala_xml"],
  visibility = ["//visibility:public"],
  )
