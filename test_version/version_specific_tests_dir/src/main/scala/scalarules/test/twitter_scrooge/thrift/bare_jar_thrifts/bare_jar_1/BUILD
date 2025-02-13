load("@rules_scala//thrift:thrift.bzl", "thrift_library")

thrift_library(
    name = "bar",
    srcs = ["//src/main/resources/scalarules/test:Bar.thrift"],
)

thrift_library(
    name = "bare_jar_1",
    external_jars = [
        ":libbar.jar",
    ],
    visibility = ["//visibility:public"],
)
