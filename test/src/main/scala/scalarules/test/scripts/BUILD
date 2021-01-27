load("//scala:scala.bzl", "scala_specs2_junit_test")

scala_specs2_junit_test(
    name = "pb_generate_request_test",
    size = "small",
    srcs = ["PBGenerateRequestTest.scala"],
    suffixes = ["Test"],
    deps = ["//src/scala/scripts:scala_proto_request_extractor"],
)
