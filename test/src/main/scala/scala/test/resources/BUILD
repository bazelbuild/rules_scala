
load("//scala:scala.bzl", "scala_library", "scala_specs2_junit_test", "scala_test",)

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
   srcs=glob(["**/*.txt"])
)

scala_specs2_junit_test(
    name = "TestScalaLibOnlyResources",
    srcs = ["ScalaLibOnlyResourcesTest.scala"],
    deps = [":noSrcsWithDirectFileResources"],
    size = "small",
    suffixes = ["Test"],
)

scala_specs2_junit_test(
    name = "TestScalaLibOnlyFilegroupResources",
    srcs = ["ScalaLibOnlyResourcesFilegroupTest.scala"],
    deps = [":noSrcsWithFilegroupResources"],
    size = "small",
    suffixes = ["Test"],
)

scala_specs2_junit_test(
    name = "TestScalaLibResourcesFromExternalDep",
    srcs = ["ScalaLibResourcesFromExternalDepTest.scala"],
    resources = ["@test_new_local_repo//:data"],
    size = "small",
    suffixes = ["Test"],
)

scala_test(
    name = "TestScalaLibResourcesFromExternalScalaTest",
    srcs = ["ScalaLibResourcesFromExternalScalaTest.scala"],
    resources = ["@test_new_local_repo//:data"],
    size = "small",
)
