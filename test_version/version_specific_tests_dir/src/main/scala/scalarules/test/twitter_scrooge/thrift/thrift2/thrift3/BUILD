load("@io_bazel_rules_scala//thrift:thrift.bzl", "thrift_library")
load("@io_bazel_rules_scala//twitter_scrooge:twitter_scrooge.bzl", "scrooge_scala_import")

thrift_library(
    name = "thrift3",
    srcs = ["Thrift3.thrift"],
    visibility = ["//visibility:public"],
)

# "thrift3_import" is a dependency of another scala library which checks whether "Struct3" from above "Thrift3" thrift
# is imported properly via: "import scalarules.test.twitter_scrooge.thrift.thrift2.thrift3.Struct3"

scrooge_scala_import(
    name = "thrift3_import",
    scala_jars = ["//src/main/scala/scalarules/test/twitter_scrooge:scrooge3"],
    thrift_jars = ["libthrift3.jar"],
    visibility = ["//visibility:public"],
)
