load(
    "@io_bazel_rules_scala//scala:scala.bzl",
    "scala_library",
)


scala_library(
    name = "resources-scala",
    resource_strip_prefix = "dataproducts/bazelTest/src/main/resources",
    resources = ["//dataproducts/bazelTest/src/main/resources:input/inputFile.txt"],
)