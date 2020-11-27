load("//thrift:thrift.bzl", "thrift_library")

thrift_library(
    name = "thrift5",
    srcs = ["Thrift5.thrift"],
    compiler_args = ["--namespace-map", "scalarules.test.twitter_scrooge.thrift.thrift_with_compiler_args.thrift5=scalarules.test.twitter_scrooge.thrift.thrift_with_compiler_args.thrift999"],
    visibility = ["//visibility:public"],
)
