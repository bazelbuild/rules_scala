load("//scala:scala.bzl", "scala_library", "scala_specs2_junit_test", "scala_test")

scala_library(
    name = "noSrcsWithDirectFileResources",
    resources = ["resource.txt"],
)

scala_library(
    name = "noSrcsWithFilegroupResources",
    resources = [":resource-fg"],
)

filegroup(
    name = "resource-fg",
    srcs = glob(["**/*.txt"]),
)

scala_specs2_junit_test(
    name = "TestScalaLibOnlyResources",
    size = "small",
    srcs = ["ScalaLibOnlyResourcesTest.scala"],
    suffixes = ["Test"],
    unused_dependency_checker_mode = "off",
    deps = [":noSrcsWithDirectFileResources"],
)

scala_specs2_junit_test(
    name = "TestScalaLibOnlyFilegroupResources",
    size = "small",
    srcs = ["ScalaLibOnlyResourcesFilegroupTest.scala"],
    suffixes = ["Test"],
    unused_dependency_checker_mode = "off",
    deps = [":noSrcsWithFilegroupResources"],
)

scala_specs2_junit_test(
    name = "TestScalaLibResourcesFromExternalDep",
    size = "small",
    srcs = ["ScalaLibResourcesFromExternalDepTest.scala"],
    resources = ["@test_new_local_repo//:data"],
    suffixes = ["Test"],
)

scala_test(
    name = "TestScalaLibResourcesFromExternalScalaTest",
    size = "small",
    srcs = ["ScalaLibResourcesFromExternalScalaTest.scala"],
    resources = ["@test_new_local_repo//:data"],
)
