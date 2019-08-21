package(default_visibility = ["//visibility:public"])

load("//scala:scala.bzl", "scala_binary", "scala_library", "scala_test")

scala_library(
    name = "user",
    srcs = [
        "A.scala",
    ],
    deps = ["dependency"],
)

scala_library(
    name = "dependency",
    srcs = [
        "B.scala",
        "C.java",
    ],
)
