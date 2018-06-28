load("//thrift:thrift.bzl", "thrift_library")

thrift_library(
    name = "thrift2_a",
    srcs = ["Thrift2_A.thrift"],
    visibility = ["//visibility:public"],
    deps = ["//test/src/main/scala/scalarules/test/twitter_scrooge/thrift/thrift2/thrift3"],
)

thrift_library(
    name = "thrift2_b",
    srcs = ["Thrift2_B.thrift"],
    visibility = ["//visibility:public"],
    deps = ["//test/src/main/scala/scalarules/test/twitter_scrooge/thrift/thrift2/thrift3"],
)

thrift_library(
    name = "thrift2_b_imp",
    srcs = ["Thrift2_B.thrift"],
    visibility = ["//visibility:public"],
    deps = ["//test/src/main/scala/scalarules/test/twitter_scrooge/thrift/thrift2/thrift3:thrift3_import"],
)
