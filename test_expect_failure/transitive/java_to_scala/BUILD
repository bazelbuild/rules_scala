load("@rules_java//java:defs.bzl", "java_library")
load("//scala:scala.bzl", "scala_library")

scala_library(
    name = "a",
    srcs = ["A.scala"],
)

java_library(
    name = "c",
    srcs = ["C.java"],
    deps = [":a"],
)

java_library(
    name = "d",
    srcs = ["D.java"],
    tags = ["manual"],
    deps = [":c"],
)
