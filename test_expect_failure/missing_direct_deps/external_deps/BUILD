package(default_visibility = ["//visibility:public"])
load("//scala:scala.bzl", "scala_library", "scala_test")

scala_library(
    name="transitive_external_dependency_user",
    srcs=[
        "A.scala",
        ],
    deps = ["external_dependency_user"],
)

scala_library(
    name="external_dependency_user",
    srcs=[
        "B.scala",
        ],
    deps = ["@com_google_guava_guava_21_0//jar"],
)

scala_library(
    name="transitive_external_dependency_user_file_group",
    srcs=[
        "A.scala",
        ],
    deps = ["external_dependency_user_file_group"],
)

scala_library(
    name="external_dependency_user_file_group",
    srcs=[
        "B.scala",
        ],
    deps = ["@com_google_guava_guava_21_0//jar:file"],
)