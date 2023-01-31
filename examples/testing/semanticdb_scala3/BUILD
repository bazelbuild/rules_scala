load("@io_bazel_rules_scala//scala:scala_toolchain.bzl", "scala_toolchain")
load("@io_bazel_rules_scala//scala:scala.bzl", "scala_binary", "scala_library")

scala_toolchain(
    name = "semanticdb_toolchain_impl",
    enable_semanticdb = True,
    visibility = ["//visibility:public"],
)

toolchain(
    name = "semanticdb_toolchain",
    toolchain = "semanticdb_toolchain_impl",
    toolchain_type = "@io_bazel_rules_scala//scala:toolchain_type",
    visibility = ["//visibility:public"],
)

scala_library(
    name = "all",
    srcs = glob(["**/*.scala"]),
)

scala_binary(
    name = "run",
    main_class = "main",
    deps = [":all"],
)
