load("//scala:scala.bzl", "scala_binary")
load("//thrift:thrift.bzl", "thrift_library")
load("//twitter_scrooge:twitter_scrooge.bzl", "scrooge_scala_library")

filegroup(
    name = "barejar",
    srcs= ["bare-thrift.jar"]
)

thrift_library(
    name = "barethriftlib",
    external_jars = [":barejar"]
)

scrooge_scala_library(
    name = "bare_thrifts",
    visibility = ["//visibility:public"],
    deps = [":barethriftlib"]
)

scala_binary(
    name = "barethrifts",
    srcs = ["BareThrifts.scala"],
    deps = [":bare_thrifts"],
    main_class = "scala.test.twitter_scrooge.BareThrifts",
)
