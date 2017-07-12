package(default_visibility = ["//visibility:public"])
load("//scala:scala.bzl", "scala_library", "scala_test")

scala_library(
    name="transitive_dependency_user",
    srcs=[
        "A.scala",
        ],
    deps = ["direct_dependency"],
    dependency_analyzer_mode = "off"
)

scala_library(
    name="direct_dependency",
    srcs=[
        "B.scala",
        ],
    deps = ["transitive_dependency"],
)

scala_library(
    name="transitive_dependency",
    srcs=[
        "C.scala",
        ],
)