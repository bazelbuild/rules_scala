package(default_visibility = ["//visibility:public"])
load("//scala:scala.bzl", "scala_library", "scala_test", "scala_binary")

scala_library(
    name="transitive_dependency_user",
    srcs=[
        "A.scala",
        ],
    deps = ["direct_dependency"],    
    dependency_analyzer_mode_soon_to_be_removed="error",
)

scala_library(
    name="direct_dependency",
    srcs=[
        "B.scala",
        ],
    deps = ["transitive_dependency"],
    dependency_analyzer_mode_soon_to_be_removed="error",
)

scala_library(
    name="transitive_dependency",
    srcs=[
        "C.scala",
        ],
    dependency_analyzer_mode_soon_to_be_removed="error",
)