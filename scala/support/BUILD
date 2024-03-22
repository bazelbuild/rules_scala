load("//scala:scala.bzl", "scala_library")
load("//scala:scala_cross_version_select.bzl", "select_for_scala_version")

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
    ] + select_for_scala_version(
        any_2 = [
            "-Xlint",
            "-Ywarn-dead-code",
            "-Ywarn-numeric-widen",
            "-Ywarn-value-discard",
        ],
        any_2_13 = [
            "-Wunused:imports",
        ],
        before_2_13 = [
            "-Yno-adapted-args",
            "-Xfuture",
            "-Ywarn-unused-import",
            "-Ypartial-unification",
        ],
    ),
    visibility = ["//visibility:public"],
    deps = [
        "//scala/private/toolchain_deps:scala_xml",
        "//testing/toolchain:scalatest_classpath",
    ],
)
