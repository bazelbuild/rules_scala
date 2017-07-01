load("//scala:scala.bzl", "scala_binary", "scala_library")
load("//twitter_scrooge:twitter_scrooge.bzl", "scrooge_scala_library")

scrooge_scala_library(
  name = "scrooge1",
  deps = [
    "//test/src/main/scala/scala/test/twitter_scrooge/thrift",
    ":scrooge2_a",
    ":scrooge2_b",
    ":scrooge3",
  ],
  visibility = ["//visibility:public"],
)

scrooge_scala_library(
  name = "scrooge2_a",
  deps = [
    "//test/src/main/scala/scala/test/twitter_scrooge/thrift/thrift2:thrift2_a",
    ":scrooge3",
  ],
  visibility = ["//visibility:public"],
)

scrooge_scala_library(
  name = "scrooge2_b",
  deps = [
    "//test/src/main/scala/scala/test/twitter_scrooge/thrift/thrift2:thrift2_b",
    ":scrooge3",
  ],
  visibility = ["//visibility:public"],
)

scrooge_scala_library(
  name = "scrooge3",
  deps = ["//test/src/main/scala/scala/test/twitter_scrooge/thrift/thrift2/thrift3"],
  visibility = ["//visibility:public"],
)

scrooge_scala_library(
  name = "scrooge2",
  deps = [
    "//test/src/main/scala/scala/test/twitter_scrooge/thrift/thrift2:thrift2_a",
    "//test/src/main/scala/scala/test/twitter_scrooge/thrift/thrift2:thrift2_b",
    ":scrooge3",
  ],
  visibility = ["//visibility:public"],
)

scrooge_scala_library(
  name = "scrooge4",
  deps = [
    "//test/src/main/scala/scala/test/twitter_scrooge/thrift/thrift2/thrift4:thrift4",
    ":scrooge2"
    ],
  visibility = ["//visibility:public"],
)
scrooge_scala_library(
  name = "scrooge4a",
  deps = [
    "//test/src/main/scala/scala/test/twitter_scrooge/thrift/thrift2/thrift4:thrift4a",
    ":scrooge4"
    ],
  visibility = ["//visibility:public"],
)

scrooge_scala_library(
    name = "bare_thrift_scrooge",
    deps = [
        "//test/src/main/scala/scala/test/twitter_scrooge/thrift/bare_jar_thrifts",
    ],
    visibility = ["//visibility:public"],
)

scala_library(
  name = "justscrooge1",
  srcs = ["JustScrooge1.scala"],
  deps = [":scrooge1"],
  exports = [":scrooge1"]
)

scala_library(
  name = "justscrooge2a",
  srcs = ["JustScrooge2a.scala"],
  deps = [":scrooge2_a"],
)

scala_library(
  name = "justscrooge2b",
  srcs = ["JustScrooge2b.scala"],
  deps = [":scrooge2_b"],
)

scala_library(
  name = "justscrooge3",
  srcs = ["JustScrooge3.scala"],
  deps = [":scrooge3"],
  exports = [":scrooge3"],
)

scala_library(
  name = "scrooge2_both",
  srcs = ["Scrooge2.scala"],
  deps = [":scrooge2"],
)

scala_library(
  name = "mixed",
  srcs = ["Mixed.scala"],
  deps = [
    ":justscrooge1",
    ":justscrooge2a",
    ":justscrooge2b",
    ":justscrooge3",
  ],
)

scala_library(
  name = "twodeep",
  srcs = ["Twodeep.scala"],
  deps = [":justscrooge3"],
)

scala_binary(
  name = "twodeep_binary",
  deps = [":twodeep"],
  main_class = "scala.test.twitter_scrooge.Twodeep",
)

scala_binary(
  name = "justscrooge2b_binary",
  deps = [":justscrooge2b"],
  main_class = "scala.test.twitter_scrooge.JustScrooge2b"
)

scala_library(
  name = "allscrooges",
  exports = [
    ":scrooge1",
    ":scrooge2_a",
    ":scrooge2_b",
    ":scrooge3",
  ],
)

scala_binary(
    name = "justscrooges",
    srcs = ["JustScrooge1.scala"],
    deps = [":allscrooges"],
    main_class = "scala.test.twitter_scrooge.JustScrooge1",
)

scala_library(
  name = "barethriftslib",
  srcs = ["BareThrifts.scala"],
  deps = [":bare_thrift_scrooge"],
)

scala_binary(
    name = "barethrifts",
    deps = [":bare_thrift_scrooge"],
    main_class = "scala.test.twitter_scrooge.BareThrifts",
)
