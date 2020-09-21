load("@io_bazel_rules_scala//scala:providers.bzl", "declare_deps_provider")
load("@io_bazel_rules_scala//testing/toolchain:toolchain.bzl", "scala_testing_toolchain")

scala_testing_toolchain(
    name = "testing_toolchains_with_all_deps_impl",
    dep_providers = [
        ":junit_classpath_provider",
        ":scalatest_classpath_provider",
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
