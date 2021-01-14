load("@io_bazel_rules_scala//testing/toolchain:toolchain_deps.bzl", "testing_toolchain_deps")

toolchain_type(
    name = "testing_toolchain_type",
    visibility = ["//visibility:public"],
)

testing_toolchain_deps(
    name = "junit_classpath",
    deps_id = "junit_classpath",
    visibility = ["//visibility:public"],
)

testing_toolchain_deps(
    name = "scalatest_classpath",
    deps_id = "scalatest_classpath",
    visibility = ["//visibility:public"],
)

testing_toolchain_deps(
    name = "specs2_classpath",
    deps_id = "specs2_classpath",
    visibility = ["//visibility:public"],
)

testing_toolchain_deps(
    name = "specs2_junit_classpath",
    deps_id = "specs2_junit_classpath",
    visibility = ["//visibility:public"],
)
