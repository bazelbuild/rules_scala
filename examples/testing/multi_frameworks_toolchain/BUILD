load("@io_bazel_rules_scala//scala:scala.bzl", "setup_scala_testing_toolchain")
load(":deps.bzl", "scalatest_classpath")

setup_scala_testing_toolchain(
    name = "testing_toolchain",
    junit_classpath = [
        "@io_bazel_rules_scala_junit_junit",
        "@io_bazel_rules_scala_org_hamcrest_hamcrest_core",
    ],
    scalatest_classpath = scalatest_classpath(),
    specs2_classpath = [
        "@io_bazel_rules_scala_org_specs2_specs2_common",
        "@io_bazel_rules_scala_org_specs2_specs2_core",
        "@io_bazel_rules_scala_org_specs2_specs2_fp",
        "@io_bazel_rules_scala_org_specs2_specs2_matcher",
    ],
    specs2_junit_classpath = [
        "@io_bazel_rules_scala_org_specs2_specs2_junit",
    ],
)
