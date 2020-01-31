load("//scala:scala.bzl", "scala_library")
load(":multiscala.bzl", "load_multiscala")
load_multiscala()

scala_library(
    name = "test_reporter",
    srcs = ["JUnitXmlReporter.scala"],
    scalacopts = [
        "-deprecation:true",
        "-encoding",
        "UTF-8",
        "-feature",
        "-language:existentials",
        "-language:higherKinds",
        "-language:implicitConversions",
        "-unchecked",
        "-Xfatal-warnings",
        "-Xlint",
        "-Yno-adapted-args",
        "-Ywarn-dead-code",
        "-Ywarn-numeric-widen",
        "-Ywarn-value-discard",
        "-Xfuture",
        "-Ywarn-unused-import",
        "-Ypartial-unification",
    ],
    visibility = ["//visibility:public"],
    deps = [
        "//external:io_bazel_rules_scala/dependency/scala/scala_xml",
        "//external:io_bazel_rules_scala/dependency/scalatest/scalatest",
    ],
)
