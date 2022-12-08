load("@io_bazel_rules_scala//scala:scala.bzl", "setup_scala_testing_toolchain")

setup_scala_testing_toolchain(
    name = "testing_toolchain",
    junit_classpath = [
        "@io_bazel_rules_scala_junit_junit",
        "@io_bazel_rules_scala_org_hamcrest_hamcrest_core",
    ],
    scalatest_classpath = [
        "@io_bazel_rules_scala_scalactic",
        "@io_bazel_rules_scala_scalatest",
        "@io_bazel_rules_scala_scalatest_compatible",
        "@io_bazel_rules_scala_scalatest_core",
        "@io_bazel_rules_scala_scalatest_featurespec",
        "@io_bazel_rules_scala_scalatest_flatspec",
        "@io_bazel_rules_scala_scalatest_freespec",
        "@io_bazel_rules_scala_scalatest_funspec",
        "@io_bazel_rules_scala_scalatest_funsuite",
        "@io_bazel_rules_scala_scalatest_matchers_core",
        "@io_bazel_rules_scala_scalatest_mustmatchers",
        "@io_bazel_rules_scala_scalatest_shouldmatchers",
    ],
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
