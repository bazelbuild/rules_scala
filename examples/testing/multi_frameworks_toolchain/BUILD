load("@rules_scala//scala:scala_cross_version.bzl", "repositories")
load(
    "@rules_scala//testing:testing.bzl",
    "setup_scala_testing_toolchain",
)
load("@rules_scala_config//:config.bzl", "SCALA_VERSION")

# This example uses the same toolchain deps you'd get from using
# `scala_toolchains(junit = True, scalatest = True, specs2 = True)`. It's a
# working example that we test via `test_examples.sh` that avoids introducing a
# dependency on `rules_jvm_external` (for now).
#
# Normally, you'd use `rules_jvm_external` and references to artifacts like
# `@maven//:org_scalatest_scalatest_shouldmatchers_2_13` to define custom
# classpaths.
#
# You would _not_ need to load `repositories` or `SCALA_VERSION`. This example
# needs them to test against a regression of #1706.
setup_scala_testing_toolchain(
    name = "testing_toolchain",
    junit_classpath = repositories(
        SCALA_VERSION,
        [
            "@io_bazel_rules_scala_junit_junit",
            "@io_bazel_rules_scala_org_hamcrest_hamcrest_core",
        ],
    ),
    scalatest_classpath = repositories(
        SCALA_VERSION,
        [
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
    ),
    specs2_classpath = repositories(
        SCALA_VERSION,
        [
            "@io_bazel_rules_scala_org_specs2_specs2_common",
            "@io_bazel_rules_scala_org_specs2_specs2_core",
            "@io_bazel_rules_scala_org_specs2_specs2_fp",
            "@io_bazel_rules_scala_org_specs2_specs2_matcher",
        ],
    ),
    specs2_junit_classpath = repositories(
        SCALA_VERSION,
        [
            "@io_bazel_rules_scala_org_specs2_specs2_junit",
        ],
    ),
)
