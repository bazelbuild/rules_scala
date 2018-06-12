load("//thrift:thrift.bzl", "thrift_library")
load("//twitter_scrooge:twitter_scrooge.bzl", "scrooge_scala_library")

thrift_library(
    name = "b_thrift",
    srcs = ["B.thrift"],
    absolute_prefixes = [
        "prefix_test/a",
        "prefix_test/e/f",
    ],
    visibility = ["//visibility:public"],
    deps = ["//test/src/main/scala/scala/test/twitter_scrooge/prefix_test/a/b/c/d:a_thrift"],
)

scrooge_scala_library(
    name = "d",
    visibility = ["//visibility:public"],
    deps = [
        ":b_thrift",
        "//test/src/main/scala/scala/test/twitter_scrooge/prefix_test/a/b/c/d",
    ],
)
