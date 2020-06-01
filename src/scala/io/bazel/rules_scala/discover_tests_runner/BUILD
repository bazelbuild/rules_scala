load("//scala:defs.bzl", "scala_library")

scala_library(
    name = "discover_tests_runner",
    srcs = ["DiscoverTestsRunner.scala"],
    visibility = ["//visibility:public"],
    deps = [
        "//external:io_bazel_rules_scala/dependency/com_google_protobuf/protobuf_java",
        "//src/scala/io/bazel/rules_scala/discover_tests_worker:discovered_tests_java_proto",
        "@io_bazel_rules_scala_test_interface//jar",
    ],
)
