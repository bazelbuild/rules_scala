load("//scala:scala.bzl", "scala_library")

scala_library(
    name = "parent",
    resources = ["resource.txt"],
    resource_strip_prefix = "test/src/main/scala/scalarules/test/duplicated_resources/parent/",
    visibility = ["//test/src/main/scala/scalarules/test/duplicated_resources/child:__pkg__"],
)
