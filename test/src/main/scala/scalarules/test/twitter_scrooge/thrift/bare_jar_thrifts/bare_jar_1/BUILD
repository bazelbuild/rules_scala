load("//thrift:thrift.bzl", "thrift_library")

java_import(
    name = "barejar1",
    jars = ["bare-thrift-1.jar"],
    visibility = ["//visibility:public"],
)

java_import(
    name = "bare_jar_1_remote",
    jars = ["bare_jar_1_scrooge.jar"],
    visibility = ["//visibility:public"],
)

thrift_library(
    name = "bare_jar_1",
    external_jars = [
        ":barejar1",
        ":bare_jar_1_remote",
    ],
    visibility = ["//visibility:public"],
)
