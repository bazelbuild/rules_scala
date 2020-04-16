load("//thrift:thrift.bzl", "thrift_library")
load("//twitter_scrooge:twitter_scrooge.bzl", "scrooge_scala_library")

thrift_library(
    name = "b_thrift_no_prefixes",
    srcs = ["B.thrift"],
    visibility = ["//visibility:public"],
    deps = ["//test/src/main/scala/scalarules/test/twitter_scrooge/interproject_test/project_a/src/thrift/com/project/a:a_thrift"],
)

scrooge_scala_library(
    name = "d",
    visibility = ["//visibility:public"],
    exports = [
        "//test/src/main/scala/scalarules/test/twitter_scrooge/interproject_test/project_a/src/thrift/com/project/a:d",
    ],
    deps = [
        ":b_thrift_no_prefixes",
    ],
)
