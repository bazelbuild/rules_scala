load("//thrift:thrift.bzl", "thrift_library")

thrift_library(
    name = "bare_jar_thrifts",
    srcs = ["//test/src/main/resources/scalarules/test:Foo.thrift"],
    visibility = ["//visibility:public"],
    deps = [
        "//test/src/main/scala/scalarules/test/twitter_scrooge/thrift/bare_jar_thrifts/bare_jar_1",
        "//test/src/main/scala/scalarules/test/twitter_scrooge/thrift/bare_jar_thrifts/bare_jar_2",
    ],
)
