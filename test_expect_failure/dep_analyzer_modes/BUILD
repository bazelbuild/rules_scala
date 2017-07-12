package(default_visibility = ["//visibility:public"])
load("//scala:scala.bzl", "scala_library", "scala_binary", "scala_test")

scala_library(
    name="error_mode",
    dependency_analyzer_mode="error",
    srcs=[
        "A.scala",
        ],
    deps = ["direct_dependency"],
)

scala_library(
    name="warn_mode",
    dependency_analyzer_mode="warn",
    srcs=[
        "A.scala",
        ],
    deps = ["direct_dependency"],
)

scala_library(
    name="weird_mode",
    dependency_analyzer_mode="kuki_buki",
    srcs=[
        "A.scala",
        ],
    deps = ["direct_dependency"],
)

scala_library(
    name="off_mode",
    dependency_analyzer_mode="off",
    srcs=[
        "A.scala",
        ],
    deps = ["direct_dependency"],
)


scala_library(
    name="direct_dependency",
    dependency_analyzer_mode="error",
    srcs=[
        "B.scala",
        ],
    deps = ["transitive_dependency"],
)

scala_library(
    name="transitive_dependency",
    dependency_analyzer_mode="error",
    srcs=[
        "C.scala",
        ],
)