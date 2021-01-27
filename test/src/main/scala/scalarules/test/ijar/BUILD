load("//scala:scala.bzl", "scala_library")

package(default_visibility = ["//visibility:public"])

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
