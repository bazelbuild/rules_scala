load("//thrift:thrift.bzl", "thrift_library")

thrift_library(
  name = "thrift",
  srcs = ["Thrift1.thrift"],
  deps = [
    "//test/src/main/scala/scala/test/twitter_scrooge/thrift/thrift2:thrift2_a",
    "//test/src/main/scala/scala/test/twitter_scrooge/thrift/thrift2:thrift2_b",
  ],
  visibility = ["//visibility:public"],
)
