load("//thrift:thrift.bzl", "thrift_library")

filegroup(
  name = "barejar2",
  srcs= ["bare-thrift-2.jar"],
  visibility = ["//visibility:public"],
)

thrift_library(
  name = "bare_jar_2",
  external_jars = [":barejar2"],
  visibility = ["//visibility:public"],
)
