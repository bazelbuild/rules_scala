load("//scala:scala_toolchain.bzl", "scala_toolchain")
load("//scala:scala.bzl", "scala_test")

scala_toolchain(
    name = "failing_toolchain_impl",
    # This will fail because 1M isn't enough
    scala_test_jvm_flags = ["-Xmx1M"],
    visibility = ["//visibility:public"],
)

scala_toolchain(
    name = "passing_toolchain_impl",
    # This will pass because 1G is enough
    scala_test_jvm_flags = ["-Xmx1G"],
    visibility = ["//visibility:public"],
)

toolchain(
    name = "failing_scala_toolchain",
    toolchain = "failing_toolchain_impl",
    toolchain_type = "@io_bazel_rules_scala//scala:toolchain_type",
    visibility = ["//visibility:public"],
)

toolchain(
    name = "passing_scala_toolchain",
    toolchain = "passing_toolchain_impl",
    toolchain_type = "@io_bazel_rules_scala//scala:toolchain_type",
    visibility = ["//visibility:public"],
)

scala_test(
    name = "empty_test",
    srcs = ["EmptyTest.scala"],
)

scala_test(
    name = "empty_overriding_test",
    srcs = ["EmptyTest.scala"],
    # This overrides the option passed in on the toolchain, and should BUILD, even if
    # the `failing_scala_toolchain` is used.
    jvm_flags = ["-Xmx1G"],
)
