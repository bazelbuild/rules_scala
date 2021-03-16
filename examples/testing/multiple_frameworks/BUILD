load("@io_bazel_rules_scala//testing/toolchain:toolchain.bzl", "scala_testing_toolchain")

scala_testing_toolchain(
    name = "testing_toolchain_impl",
    dep_providers = [
        "@io_bazel_rules_scala//testing:junit_classpath_provider",
        "@io_bazel_rules_scala//testing:specs2_classpath_provider",
        "@io_bazel_rules_scala//testing:specs2_junit_classpath_provider",
        "@io_bazel_rules_scala//testing:scalatest_classpath_provider",
    ],
    visibility = ["//visibility:public"],
)

toolchain(
    name = "testing_toolchain",
    toolchain = ":testing_toolchain_impl",
    toolchain_type = "@io_bazel_rules_scala//testing/toolchain:testing_toolchain_type",
    visibility = ["//visibility:public"],
)

load("@io_bazel_rules_scala//scala:scala.bzl", "scala_test")

scala_test(
    name = "scala_test_example",
    size = "small",
    srcs = ["ScalaTestExampleTest.scala"],
)

load("@io_bazel_rules_scala//scala:scala.bzl", "scala_specs2_junit_test")

scala_specs2_junit_test(
    name = "specs2_junit_example",
    size = "small",
    srcs = ["Specs2ExampleTest.scala"],
    suffixes = ["Test"],
)
