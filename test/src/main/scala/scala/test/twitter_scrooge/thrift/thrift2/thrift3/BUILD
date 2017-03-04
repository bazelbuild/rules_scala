load("//thrift:thrift.bzl", "thrift_library")

thrift_library(
  name = "thrift3",
  srcs = ["Thrift3.thrift"],
  visibility = ["//visibility:public"],
)
filegroup(
    name = "sources",
    data = glob(["**"]),
    visibility = ["//visibility:public"]
    )