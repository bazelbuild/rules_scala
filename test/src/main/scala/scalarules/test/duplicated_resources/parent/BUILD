load("//scala:scala.bzl", "scala_library")

scala_library(
    name = "parent",
    resource_strip_prefix = "test/src/main/scala/scalarules/test/duplicated_resources/parent/",
    resources = ["resource.txt"],
    visibility = ["//test/src/main/scala/scalarules/test/duplicated_resources/child:__pkg__"],
)
