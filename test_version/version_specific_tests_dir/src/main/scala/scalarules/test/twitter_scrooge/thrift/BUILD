load("@rules_scala//thrift:thrift.bzl", "thrift_library")

thrift_library(
    name = "thrift",
    srcs = ["Thrift1.thrift"],
    visibility = ["//visibility:public"],
    deps = [
        "//src/main/scala/scalarules/test/twitter_scrooge/thrift/thrift2:thrift2_a",
        "//src/main/scala/scalarules/test/twitter_scrooge/thrift/thrift2:thrift2_b",
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
