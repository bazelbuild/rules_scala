load("//thrift:thrift.bzl", "thrift_library")

filegroup(
  name = "barejar1",
  srcs= ["bare-thrift-1.jar"],
  visibility = ["//visibility:public"],
)

thrift_library(
  name = "bare_jar_1",
  external_jars = [":barejar1"],
  visibility = ["//visibility:public"],
)
