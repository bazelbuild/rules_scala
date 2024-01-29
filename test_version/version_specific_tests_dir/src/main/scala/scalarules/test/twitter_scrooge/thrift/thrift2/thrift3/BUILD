load("@io_bazel_rules_scala//thrift:thrift.bzl", "thrift_library")
load("@io_bazel_rules_scala//twitter_scrooge:twitter_scrooge.bzl", "scrooge_scala_import")

thrift_library(
    name = "thrift3",
    srcs = ["Thrift3.thrift"],
    visibility = ["//visibility:public"],
)

scrooge_scala_import(
    name = "thrift3_import",
    scala_jars = ["//src/main/scala/scalarules/test/twitter_scrooge:scrooge3"],
    thrift_jars = ["libthrift3.jar"],
    visibility = ["//visibility:public"],
)
