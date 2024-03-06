load("@io_bazel_rules_scala_config//:config.bzl", "SCALA_VERSION")
load("@io_bazel_rules_scala//scala:scala_cross_version.bzl", "version_suffix")

_SCALATEST_CLASSPATH = [
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

def scalatest_classpath():
    return [dep + version_suffix(SCALA_VERSION) for dep in _SCALATEST_CLASSPATH]
