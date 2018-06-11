load("//thrift:thrift.bzl", "thrift_library")

thrift_library(
    name = "thrift4",
    srcs = ["Thrift4.thrift"],
    visibility = ["//visibility:public"],
)

thrift_library(
    name = "thrift4a",
    srcs = ["Thrift4a.thrift"],
    visibility = ["//visibility:public"],
    deps = [":thrift4"],
)
