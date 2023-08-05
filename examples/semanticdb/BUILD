load("@io_bazel_rules_scala//scala:scala_toolchain.bzl", "scala_toolchain")
load("@io_bazel_rules_scala//scala:scala.bzl", "scala_binary", "scala_library")

scala_toolchain(
    name = "semanticdb_toolchain_impl",
    enable_semanticdb = True,
    semanticdb_bundle_in_jar = False,
    visibility = ["//visibility:public"],
)

toolchain(
    name = "semanticdb_toolchain",
    toolchain = "semanticdb_toolchain_impl",
    toolchain_type = "@io_bazel_rules_scala//scala:toolchain_type",
    visibility = ["//visibility:public"],
)

scala_library(
    name = "hello_lib",
    srcs = ["Foo.scala"],
)

scala_binary(
    name = "hello",
    srcs = ["Main.scala"],
    main_class = "main",
    deps = [":hello_lib"],
)
