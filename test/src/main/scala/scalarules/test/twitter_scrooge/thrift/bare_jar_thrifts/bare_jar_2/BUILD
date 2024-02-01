load("//thrift:thrift.bzl", "thrift_library")

thrift_library(
    name = "baz",
    srcs = ["//test/src/main/resources/scalarules/test:Baz.thrift"],
)

thrift_library(
    name = "bare_jar_2",
    external_jars = [
        ":libbaz.jar",
    ],
    visibility = ["//visibility:public"],
)
