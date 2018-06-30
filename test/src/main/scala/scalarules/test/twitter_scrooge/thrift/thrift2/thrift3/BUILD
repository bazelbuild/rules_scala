load("//thrift:thrift.bzl", "thrift_library")
load("//twitter_scrooge:twitter_scrooge.bzl", "scrooge_scala_import")

thrift_library(
    name = "thrift3",
    srcs = ["Thrift3.thrift"],
    visibility = ["//visibility:public"],
)

scrooge_scala_import(
    name = "thrift3_import",
    scala_jars = ["thrift3_scrooge.jar"],
    thrift_jars = ["libthrift3.jar"],
    visibility = ["//visibility:public"],
)
