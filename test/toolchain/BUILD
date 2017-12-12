load("//specs2:specs2_junit.bzl","specs2_junit_dependencies")
load("//scala:scala.bzl","scala_library")
load("@build_bazel_integration_test//tools:bazel_java_integration_test.bzl","bazel_java_integration_test")

scala_library(
    name = "toolchain",
    srcs = ["ScalaToolchainTest.scala"],
    deps = ["@build_bazel_integration_test//java/build/bazel/tests/integration:integration", "//external:io_bazel_rules_scala/dependency/junit/junit", "@com_google_guava_guava_21_0//jar"] + specs2_junit_dependencies(),
    testonly = 1
)

bazel_java_integration_test(
    name = "ScalaToolchainTestRunner",
    srcs = [],
    test_class = "scala.test.toolchain.ScalaToolchainTest",
    runtime_deps = [":toolchain"],
)