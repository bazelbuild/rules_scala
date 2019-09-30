load("//scala:scala.bzl", "scala_library", "scala_specs2_junit_test")
load("//scala:scala_import.bzl", "scala_import")

scala_specs2_junit_test(
    name = "pb_generate_request_test",
    size = "small",
    srcs = ["PBGenerateRequestTest.scala"],
    suffixes = ["Test"],
    deps = ["//src/scala/scripts:scala_proto_request_extractor"],
)
