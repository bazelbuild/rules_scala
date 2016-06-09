load("//scala:scala.bzl", "scala_library", "scala_export_to_java")

scala_library(
    name = "a",
    srcs = ["A.scala"]
)

scala_export_to_java(
    name = "b",
    exports = [":a"],
    runtime_deps = []
)

java_library(
    name = "c",
    srcs = ["C.java"],
    deps = [":b"],
)

java_library(
    name = "d",
    srcs = ["D.java"],
    deps = [":c"],
)
