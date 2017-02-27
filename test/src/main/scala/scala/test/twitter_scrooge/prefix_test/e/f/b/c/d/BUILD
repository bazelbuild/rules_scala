load("//thrift:thrift.bzl", "thrift_library")
load("//twitter_scrooge:twitter_scrooge.bzl", "scrooge_scala_library")

thrift_library(
  name = "b_thrift",
  srcs = ["B.thrift"],
  deps = ["//test/src/main/scala/scala/test/twitter_scrooge/prefix_test/a/b/c/d:a_thrift"],
  absolute_prefixes = ["prefix_test/a", "prefix_test/e/f"],
  visibility = ["//visibility:public"],
)

scrooge_scala_library(
  name = "d",
  deps = [
    "//test/src/main/scala/scala/test/twitter_scrooge/prefix_test/a/b/c/d",
    ":b_thrift",
  ],
  visibility = ["//visibility:public"],
)
