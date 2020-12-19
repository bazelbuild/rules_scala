load("//scala:scala_toolchain.bzl", "scala_toolchain")
load("//scala:scala.bzl", "scala_test")

scala_toolchain(
    name = "failing_toolchain_impl",
    # This will fail because :failing_jacocorunner is not a valid JacocoRunner.
    jacocorunner = ":failing_jacocorunner",
    visibility = ["//visibility:public"],
)

toolchain(
    name = "failing_scala_toolchain",
    toolchain = "failing_toolchain_impl",
    toolchain_type = "@io_bazel_rules_scala//scala:toolchain_type",
    visibility = ["//visibility:public"],
)

scala_test(
    name = "empty_test",
    srcs = ["EmptyTest.scala"],
)

filegroup(
    name = "failing_jacocorunner",
    srcs = ["EmptyTest.scala"],
)
