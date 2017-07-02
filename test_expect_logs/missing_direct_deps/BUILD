package(default_visibility = ["//visibility:public"])
load("//scala:scala.bzl", "scala_library", "scala_test")

scala_library(
    name="transitive_dependency_user",
    srcs=[
        "A.scala",
        ],
    deps = ["direct_dependency"],
#    plugins = ["@classpath_shrinker//jar"],
)

scala_library(
    name="direct_dependency",
    srcs=[
        "B.scala",
        ],
    deps = ["transitive_dependency"],
#        plugins = ["@classpath_shrinker//jar"],

)

scala_library(
    name="transitive_dependency",
    srcs=[
        "C.scala",
        ],
#            plugins = ["@classpath_shrinker//jar"],

)