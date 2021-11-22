load("//scala:scala.bzl", "scala_library", "scala_test")

scala_library(
    name = "empty-lib-with-resources",
    resource_strip_prefix = "test/resource_packaging",
    resources = ["a/b/xxx.txt"],
)

scala_test(
  name = "test",
  srcs = ["Test.scala"],
  deps = [":empty-lib-with-resources"],
  # We are testing the behavior on only resources, so this could
  # trigger unused dep failures.
  unused_dependency_checker_mode = "off",
)
