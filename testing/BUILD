load("@io_bazel_rules_scala//scala:scala.bzl", "setup_scala_testing_toolchain")
load("//scala:scala_cross_version.bzl", "version_suffix")
load("@io_bazel_rules_scala_config//:config.bzl", "SCALA_VERSION")

_SPECS2_DEPS = [
    "@io_bazel_rules_scala_org_specs2_specs2_common",
    "@io_bazel_rules_scala_org_specs2_specs2_core",
    "@io_bazel_rules_scala_org_specs2_specs2_fp",
    "@io_bazel_rules_scala_org_specs2_specs2_matcher",
]

_SPECS2_JUNIT_DEPS = [
    "@io_bazel_rules_scala_org_specs2_specs2_junit",
]

_JUNIT_DEPS = [
    "@io_bazel_rules_scala_junit_junit",
    "@io_bazel_rules_scala_org_hamcrest_hamcrest_core",
]

_SCALATEST_DEPS = [
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
]

setup_scala_testing_toolchain(
    name = "testing_toolchain",
    junit_classpath = _JUNIT_DEPS,
    scalatest_classpath = [dep + version_suffix(SCALA_VERSION) for dep in _SCALATEST_DEPS],
    specs2_classpath = _SPECS2_DEPS,
    specs2_junit_classpath = _SPECS2_JUNIT_DEPS,
    visibility = ["//visibility:public"],
)

setup_scala_testing_toolchain(
    name = "scalatest_toolchain",
    scalatest_classpath = [dep + version_suffix(SCALA_VERSION) for dep in _SCALATEST_DEPS],
    visibility = ["//visibility:public"],
)

setup_scala_testing_toolchain(
    name = "specs2_junit_toolchain",
    junit_classpath = _JUNIT_DEPS,
    specs2_classpath = _SPECS2_DEPS,
    specs2_junit_classpath = _SPECS2_JUNIT_DEPS,
    visibility = ["//visibility:public"],
)

setup_scala_testing_toolchain(
    name = "junit_toolchain",
    junit_classpath = _JUNIT_DEPS,
    visibility = ["//visibility:public"],
)
