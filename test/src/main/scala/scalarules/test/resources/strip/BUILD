load("//scala:scala.bzl", "scala_library", "scala_specs2_junit_test")

scala_library(
    name = "noSrcsWithResources",
    resource_strip_prefix = "test/src/main/scala/scalarules/test/resources/strip",
    resources = ["nosrc_jar_resource.txt"],
)

scala_specs2_junit_test(
    name = "resouceStripPrefixTest",
    size = "small",
    srcs = ["ResourceStripPrefixTest.scala"],
    suffixes = ["Test"],
    unused_dependency_checker_mode = "off",
    deps = [":noSrcsWithResources"],
)
