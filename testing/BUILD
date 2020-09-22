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

scala_testing_toolchain(
    name = "scalatest_toolchain_impl",
    dep_providers = [
        ":scalatest_classpath_provider",
    ],
    visibility = ["//visibility:public"],
)

toolchain(
    name = "scalatest_toolchain",
    toolchain = ":scalatest_toolchain_impl",
    toolchain_type = "@io_bazel_rules_scala//testing/toolchain:testing_toolchain_type",
    visibility = ["//visibility:public"],
)

scala_testing_toolchain(
    name = "specs2_toolchain_impl",
    dep_providers = [
        ":specs2_classpath_provider",
    ],
    visibility = ["//visibility:public"],
)

toolchain(
    name = "specs2_toolchain",
    toolchain = ":specs2_toolchain_impl",
    toolchain_type = "@io_bazel_rules_scala//testing/toolchain:testing_toolchain_type",
    visibility = ["//visibility:public"],
)

scala_testing_toolchain(
    name = "specs2_junit_toolchain_impl",
    dep_providers = [
        ":specs2_classpath_provider",
        ":specs2_junit_classpath_provider",
    ],
    visibility = ["//visibility:public"],
)

toolchain(
    name = "specs2_junit_toolchain",
    toolchain = ":specs2_toolchain_impl",
    toolchain_type = "@io_bazel_rules_scala//testing/toolchain:testing_toolchain_type",
    visibility = ["//visibility:public"],
)

scala_testing_toolchain(
    name = "junit_toolchain_impl",
    dep_providers = [
        ":junit_classpath_provider",
    ],
    visibility = ["//visibility:public"],
)

toolchain(
    name = "junit_toolchain",
    toolchain = ":junit_toolchain_impl",
    toolchain_type = "@io_bazel_rules_scala//testing/toolchain:testing_toolchain_type",
    visibility = ["//visibility:public"],
)

declare_deps_provider(
    name = "junit_classpath_provider",
    deps_id = "junit_classpath",
    visibility = ["//visibility:public"],
    deps = [
        "//external:io_bazel_rules_scala/dependency/hamcrest/hamcrest_core",
        "//external:io_bazel_rules_scala/dependency/junit/junit",
    ],
)

declare_deps_provider(
    name = "scalatest_classpath_provider",
    deps_id = "scalatest_classpath",
    visibility = ["//visibility:public"],
    deps = [
        "//external:io_bazel_rules_scala/dependency/scala/scalactic/scalactic",
        "//external:io_bazel_rules_scala/dependency/scala/scalatest/scalatest",
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
        "//external:io_bazel_rules_scala/dependency/specs2/specs2_junit",
    ],
)
