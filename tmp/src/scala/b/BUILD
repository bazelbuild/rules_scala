load("//scala:scala.bzl", "scala_binary", "scala_library")

scala_library(
    name = "b",
    srcs = ["B.scala"],
    deps = ["//tmp/src/scala/c:c"],
    visibility = ["//visibility:public"],
    # unused_deps_always_off=True,
)