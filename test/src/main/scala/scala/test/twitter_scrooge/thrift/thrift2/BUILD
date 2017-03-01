load("//thrift:thrift.bzl", "thrift_library")

thrift_library(
  name = "thrift2_a",
  srcs = ["Thrift2_A.thrift"],
  deps = ["//test/src/main/scala/scala/test/twitter_scrooge/thrift/thrift2/thrift3"],
  visibility = ["//visibility:public"],
)

thrift_library(
  name = "thrift2_b",
  srcs = ["Thrift2_B.thrift"],
  deps = ["//test/src/main/scala/scala/test/twitter_scrooge/thrift/thrift2/thrift3"],
  visibility = ["//visibility:public"],
)

filegroup(
    name = "sources",
    data = glob(["**"]),
    visibility = ["//visibility:public"]
    )