load("//scala:scala.bzl", "scala_library")
load("//scala:scala_toolchain.bzl", "scala_toolchain")

toolchain(
    name = "plus_one_strict_deps_filter",
    toolchain = ":plus_one_strict_deps_filter_a_impl",
    toolchain_type = "@io_bazel_rules_scala//scala:toolchain_type",
    visibility = ["//visibility:public"],
)

scala_toolchain(
    name = "plus_one_strict_deps_filter_a_impl",
    dependency_mode = "plus-one",
    dependency_tracking_method = "ast",
    dependency_tracking_strict_deps_patterns = [
        "//test_expect_failure/missing_direct_deps/filtering",
        "-//test_expect_failure/missing_direct_deps/filtering:a",
    ],
    strict_deps_mode = "error",
    visibility = ["//visibility:public"],
)

scala_library(
    name = "transitive_deps",
    testonly = True,
    srcs = ["UsesGuava.scala"],
    deps = ["@com_google_guava_guava_21_0"],
)

scala_library(
    name = "a",
    testonly = True,
    srcs = ["UsesGuava.scala"],
    deps = [":transitive_deps"],
)

scala_library(
    name = "b",
    testonly = True,
    srcs = ["UsesGuava.scala"],
    deps = [":transitive_deps"],
)
