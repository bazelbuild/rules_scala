load("//thrift:thrift.bzl", "thrift_library")

thrift_library(
    name = "thrift4",
    srcs = ["Thrift4.thrift"],
    visibility = ["//visibility:public"],
    deps = [
        "//test/src/main/scala/scalarules/test/twitter_scrooge/thrift/thrift2:thrift2_a",
    ],
)

thrift_library(
    name = "thrift4a",
    srcs = ["Thrift4a.thrift"],
    visibility = ["//visibility:public"],
    deps = [
        ":thrift4",
        "//test/src/main/scala/scalarules/test/twitter_scrooge/thrift/thrift2:thrift2_a",
    ],
)
