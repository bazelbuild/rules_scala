
load("//scala:scala.bzl", "scala_library")

# Testing Resources without srcs
scala_library(
   name = "noSrcsResources",
   resources  = ["resource.txt"]
)

# Testing filegroup resources without srcs 
scala_library(
   name = "noSrcsFilegroupResources",
   resources = [":resource-fg"]
)

filegroup(
   name="resource-fg",
   srcs=["resource.txt"]
)