load(":analyzer_test.bzl", "tests")
load("//scala:scala.bzl", "scala_test")

tests()

scala_test(
    name = "test_optionsparser",
    srcs = ["test_optionsparser.scala"],
    deps = ["//third_party/dependency_analyzer/src/main:dependency_analyzer"],
)
