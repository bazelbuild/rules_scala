load("//scala:scala.bzl", "scala_library")

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
        "//scala/private/toolchain_deps:scala_xml",
        "//testing/toolchain:scalatest_classpath",
    ],
)
