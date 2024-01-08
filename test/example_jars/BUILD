load("@rules_java//java:defs.bzl", "java_library")

java_library(
    name = "example_jar1",
    resources = [
        "//test/src/main/resources/META-INF/services:org.apache.beam.sdk.io.FileSystemRegistrar"
    ],
    visibility = ["//visibility:public"]
)

java_library(
    name = "example_jar2",
    resources = [
        "//test/src/main/resources/META-INF/services:org.apache.beam.sdk.io.FileSystemRegistrar"
    ],
    visibility = ["//visibility:public"],
)
