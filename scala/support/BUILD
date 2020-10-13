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
        #  TODO: commented out due to Scala 2.13 "-Yno-adapted-args",
        "-Ywarn-dead-code",
        "-Ywarn-numeric-widen",
        "-Ywarn-value-discard",
        #  TODO: commented out due to Scala 2.13       "-Xfuture",
        #  TODO: commented out due to Scala 2.13       "-Ywarn-unused-import",
        #  TODO: commented out due to Scala 2.13       "-Ypartial-unification",
    ],
    visibility = ["//visibility:public"],
    deps = [
        "//scala/private/toolchain_deps:scala_xml",
        "//testing/toolchain:scalatest_classpath",
    ],
)
