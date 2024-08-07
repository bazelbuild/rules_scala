load("@io_bazel_rules_scala//thrift:thrift.bzl", "thrift_library")

thrift_library(
    name = "foo",
    srcs = ["//src/main/resources/scalarules/test:Foo.thrift"],
)

thrift_library(
    name = "bare_jar_thrifts",
    external_jars = [
        ":libfoo.jar",
    ],
    visibility = ["//visibility:public"],
    deps = [
        "//src/main/scala/scalarules/test/twitter_scrooge/thrift/bare_jar_thrifts/bare_jar_1",
        "//src/main/scala/scalarules/test/twitter_scrooge/thrift/bare_jar_thrifts/bare_jar_2",
    ],
)
