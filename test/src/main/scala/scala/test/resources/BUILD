
load("//scala:scala.bzl", "scala_library")

scala_library(
   name = "noSrcsWithDirectFileResources",
   resources  = ["resource.txt"]
)

scala_library(
   name = "noSrcsWithFilegroupResources",
   resources = [":resource-fg"]
)

filegroup(
   name="resource-fg",
   srcs=["resource.txt"]
)