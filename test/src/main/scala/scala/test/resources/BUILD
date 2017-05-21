
load("//scala:scala.bzl", "scala_library")

# Test of resources with srcs
scala_library(
    name = "yesSrcsResources",
    srcs = ["DummyStandAlone.scala"],
    resources  = ["resource.txt"]
    )

# Testing Resources without srcs
scala_library(
    name = "noSrcsResources",
    resources  = ["resource.txt"]
    )

# Testing filegroup resources with srcs
scala_library(
    name = "yesSrcsFilegroupResources",
    srcs = ["DummyStandAlone.scala"],
	resources = [":resource-fg"]
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