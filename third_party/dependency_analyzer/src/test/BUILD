load(":analyzer_test.bzl", "tests")
load("//scala:scala.bzl", "scala_test")
load("@io_bazel_rules_scala_config//:config.bzl", "SCALA_VERSION")
load("@io_bazel_rules_scala//scala:scala_cross_version.bzl", "version_suffix")

tests()

scala_test(
    name = "test_optionsparser",
    srcs = ["test_optionsparser.scala"],
    deps = ["//third_party/dependency_analyzer/src/main:dependency_analyzer" + version_suffix(SCALA_VERSION)],
)
