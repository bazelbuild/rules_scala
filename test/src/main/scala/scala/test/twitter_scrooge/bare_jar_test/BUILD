load("//scala:scala.bzl", "scala_binary", "scala_library")
load("//thrift:thrift.bzl", "thrift_library")
load("//twitter_scrooge:twitter_scrooge.bzl", "scrooge_scala_library")

java_import(
    name = "barejar",
    jars = ["bare-thrift.jar"]
)

scrooge_scala_library(
    name = "bare_thrifts",
    visibility = ["//visibility:public"],
    remote_self_jars = [":barejar"]
)

scala_binary(
    name = "barethrifts",
    srcs = ["BareThrifts.scala"],
    deps = [":bare_thrifts"],
    main_class = "scala.test.twitter_scrooge.BareThrifts",
)
