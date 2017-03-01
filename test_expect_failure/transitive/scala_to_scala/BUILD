load("//scala:scala.bzl", "scala_library")

scala_library(
    name = "a",
    srcs = ["A.scala"]
)

scala_library(
    name = "b",
    exports = [":a"],
)

scala_library(
    name = "c",
    deps = [":b"],
)

scala_library(
    name = "d",
    deps = [":c"],
    srcs = ["D.scala"],
    tags = ["manual"],
)

filegroup(
    name = "sources",
    data = glob(["**"]),
    visibility = ["//visibility:public"]
    )