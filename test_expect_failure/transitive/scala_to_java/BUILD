load("//scala:scala.bzl", "scala_library")

java_library(
    name = "a",
    srcs = ["A.java"]
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
