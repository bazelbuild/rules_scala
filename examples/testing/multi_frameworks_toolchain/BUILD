load("@io_bazel_rules_scala//scala:providers.bzl", "declare_deps_provider")
load("@io_bazel_rules_scala//testing/toolchain:toolchain.bzl", "scala_testing_toolchain")

scala_testing_toolchain(
    name = "testing_toolchains_with_all_deps_impl",
    dep_providers = [
        ":junit_classpath_provider",
        ":scalatest_classpath_provider",
        ":specs2_classpath_provider",
        ":specs2_junit_classpath_provider",
    ],
    visibility = ["//visibility:public"],
)

toolchain(
    name = "testing_toolchain",
    toolchain = ":testing_toolchains_with_all_deps_impl",
    toolchain_type = "@io_bazel_rules_scala//testing/toolchain:testing_toolchain_type",
    visibility = ["//visibility:public"],
)

declare_deps_provider(
    name = "junit_classpath_provider",
    deps_id = "junit_classpath",
    visibility = ["//visibility:public"],
    deps = [
        "@io_bazel_rules_scala_junit_junit",
        "@io_bazel_rules_scala_org_hamcrest_hamcrest_core",
    ],
)

declare_deps_provider(
    name = "scalatest_classpath_provider",
    deps_id = "scalatest_classpath",
    visibility = ["//visibility:public"],
    deps = [
        "@io_bazel_rules_scala_scalactic",
        "@io_bazel_rules_scala_scalatest",
    ],
)

declare_deps_provider(
    name = "specs2_classpath_provider",
    deps_id = "specs2_classpath",
    visibility = ["//visibility:public"],
    deps = [
        "@io_bazel_rules_scala_org_specs2_specs2_common",
        "@io_bazel_rules_scala_org_specs2_specs2_core",
        "@io_bazel_rules_scala_org_specs2_specs2_fp",
        "@io_bazel_rules_scala_org_specs2_specs2_matcher",
    ],
)

declare_deps_provider(
    name = "specs2_junit_classpath_provider",
    deps_id = "specs2_junit_classpath",
    visibility = ["//visibility:public"],
    deps = [
        "@io_bazel_rules_scala_org_specs2_specs2_junit",
    ],
)
