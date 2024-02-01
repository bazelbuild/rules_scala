load("//scala:scala.bzl", "scala_library")

scala_library(
    name = "example_jar1",
    resources = [
        "//test/src/main/resources/META-INF/services:org.apache.beam.sdk.io.FileSystemRegistrar",
    ],
    visibility = ["//visibility:public"],
)

scala_library(
    name = "example_jar2",
    resource_strip_prefix = "{}/{}".format(
        package_name(),
        "src/main/resources",
    ),
    resources = ["src/main/resources/META-INF/services/org.apache.beam.sdk.io.FileSystemRegistrar"],
    visibility = ["//visibility:public"],
)
