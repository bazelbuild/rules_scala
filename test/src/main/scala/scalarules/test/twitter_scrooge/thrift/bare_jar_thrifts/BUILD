load("//thrift:thrift.bzl", "thrift_library")

java_import(
    name = "barejar",
    jars = ["bare-thrift.jar"],
    visibility = ["//visibility:public"],
)

java_import(
    name = "barejar_java_import",
    jars = ["bare_jar_thrifts_scrooge.jar"],
    visibility = ["//visibility:public"],
)

thrift_library(
    name = "bare_jar_thrifts",
    external_jars = [
        ":barejar",
        ":barejar_java_import",
    ],
    visibility = ["//visibility:public"],
    deps = [
        "//test/src/main/scala/scalarules/test/twitter_scrooge/thrift/bare_jar_thrifts/bare_jar_1",
        "//test/src/main/scala/scalarules/test/twitter_scrooge/thrift/bare_jar_thrifts/bare_jar_2",
    ],
)
