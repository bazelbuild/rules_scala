load("//scala:scala.bzl", "scala_library")

scala_library(
    name = "test-lib",
    srcs = glob(
        ["src/test/scala/**/*.scala"],
    ),
    resource_strip_prefix = "test/resource_strip_prefix/src/test/resources",
    resources = ["src/test/resources/resource.txt"],
)
