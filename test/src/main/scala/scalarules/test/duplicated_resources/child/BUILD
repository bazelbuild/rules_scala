load("//scala:scala.bzl", "scala_test")

# https://github.com/bazelbuild/rules_scala/issues/1455
scala_test(
    name = "child",
    size = "small",
    srcs = ["ScalaLibResourcesDuplicatedTest.scala"],
    resource_strip_prefix = "test/src/main/scala/scalarules/test/duplicated_resources/child/",
    resources = ["resource.txt"],
    unused_dependency_checker_mode = "off",
    deps = ["//test/src/main/scala/scalarules/test/duplicated_resources/parent"],
)
