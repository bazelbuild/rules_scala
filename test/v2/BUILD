load(
    "//scala:defs.bzl",
    "scala_binary",
    "scala_library",
    "scala_test",
)

scala_binary(
    name = "binary",
    srcs = ["binary.scala"],
    main_class = "test.v2.Binary",
    deps = [":library"],
)

scala_library(
    name = "library",
    srcs = ["library.scala"],
    deps = [],
)

scala_test(
    name = "test",
    srcs = ["test.scala"],
    deps = [
        ":library",
        "//external:io_bazel_rules_scala/dependency/scalatest/scalatest",
    ],
)
