load("//thrift:thrift.bzl", "thrift_library")

thrift_library(
    name = "thrift",
    srcs = ["Thrift1.thrift"],
    visibility = ["//visibility:public"],
    deps = [
        "//test/src/main/scala/scalarules/test/twitter_scrooge/thrift/thrift2:thrift2_a",
        "//test/src/main/scala/scalarules/test/twitter_scrooge/thrift/thrift2:thrift2_b",
    ],
)

thrift_library(
    name = "thrift_many",
    srcs = [
        "ThriftMany1.thrift",
        "ThriftMany2.thrift",
    ],
    visibility = ["//visibility:public"],
)

thrift_library(
    name = "thrift_service",
    srcs = ["ThriftService.thrift"],
    visibility = ["//visibility:public"],
    deps = [
        ":thrift",
    ],
)
