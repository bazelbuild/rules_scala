load("//scala:scala.bzl", "scala_library")

scala_library(
    name = "compiler",
    srcs = ["Compiler.scala"],
    # util_core is still needed as a dep for older versions of scrooge
    unused_dependency_checker_mode = "off",
    visibility = ["//visibility:public"],
    deps = [
        ":focused_zip_importer",
        "//external:io_bazel_rules_scala/dependency/scala/guava",
        "//external:io_bazel_rules_scala/dependency/scala/parser_combinators",
        "//external:io_bazel_rules_scala/dependency/thrift/mustache",
        "//external:io_bazel_rules_scala/dependency/thrift/scrooge_generator",
        "//external:io_bazel_rules_scala/dependency/thrift/util_core",
        "//external:io_bazel_rules_scala/dependency/thrift/util_logging",
    ],
)

scala_library(
    name = "focused_zip_importer",
    srcs = ["FocusedZipImporter.scala"],
    visibility = ["//visibility:public"],
    deps = [
        "//external:io_bazel_rules_scala/dependency/thrift/scrooge_generator",
    ],
)
