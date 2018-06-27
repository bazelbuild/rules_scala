load("//thrift:thrift.bzl", "thrift_library")

java_import(
    name = "barejar2",
    jars = ["bare-thrift-2.jar"],
    visibility = ["//visibility:public"],
)

java_import(
    name = "bare_jar_2_remote",
    jars = ["bare_jar_2_scrooge.jar"],
    visibility = ["//visibility:public"],
)

thrift_library(
    name = "bare_jar_2",
    external_jars = [
        ":barejar2",
        ":bare_jar_2_remote",
    ],
    visibility = ["//visibility:public"],
)
