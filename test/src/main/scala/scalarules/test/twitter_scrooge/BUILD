load("//scala:scala.bzl", "scala_binary", "scala_library")
load("//twitter_scrooge:twitter_scrooge.bzl", "scrooge_scala_library")
load("//thrift:thrift.bzl", "thrift_library")
load("//test/src/main/scala/scalarules/test/twitter_scrooge:twitter_scrooge_test.bzl", "twitter_scrooge_test_suite")

scrooge_scala_library(
    name = "scrooge1",
    visibility = ["//visibility:public"],
    exports = [
        ":scrooge2_a",
        ":scrooge2_b",
        ":scrooge3",
    ],
    deps = ["//test/src/main/scala/scalarules/test/twitter_scrooge/thrift"],
)

scrooge_scala_library(
    name = "scrooge2_a",
    visibility = ["//visibility:public"],
    exports = [
        ":scrooge3",
    ],
    deps = [
        "//test/src/main/scala/scalarules/test/twitter_scrooge/thrift/thrift2:thrift2_a",
    ],
)

scrooge_scala_library(
    name = "scrooge2_b",
    visibility = ["//visibility:public"],
    exports = [
        ":scrooge3",
    ],
    deps = [
        "//test/src/main/scala/scalarules/test/twitter_scrooge/thrift/thrift2:thrift2_b",
    ],
)

scrooge_scala_library(
    name = "scrooge2_b_imp",
    deps = [
        "//test/src/main/scala/scalarules/test/twitter_scrooge/thrift/thrift2:thrift2_b_imp",
    ],
)

scrooge_scala_library(
    name = "scrooge3",
    visibility = ["//visibility:public"],
    deps = ["//test/src/main/scala/scalarules/test/twitter_scrooge/thrift/thrift2/thrift3"],
)

scrooge_scala_library(
    name = "scrooge2",
    visibility = ["//visibility:public"],
    exports = [
        ":scrooge3",
    ],
    deps = [
        "//test/src/main/scala/scalarules/test/twitter_scrooge/thrift/thrift2:thrift2_a",
        "//test/src/main/scala/scalarules/test/twitter_scrooge/thrift/thrift2:thrift2_b",
    ],
)

scrooge_scala_library(
    name = "scrooge4",
    visibility = ["//visibility:public"],
    exports = [
        ":scrooge2",
    ],
    deps = [
        "//test/src/main/scala/scalarules/test/twitter_scrooge/thrift/thrift2/thrift4",
    ],
)

scrooge_scala_library(
    name = "scrooge4a",
    visibility = ["//visibility:public"],
    exports = [
        ":scrooge4",
    ],
    deps = [
        "//test/src/main/scala/scalarules/test/twitter_scrooge/thrift/thrift2/thrift4:thrift4a",
    ],
)

scrooge_scala_library(
    name = "scroogebarejar1",
    visibility = ["//visibility:public"],
    deps = [
        "//test/src/main/scala/scalarules/test/twitter_scrooge/thrift/bare_jar_thrifts/bare_jar_1",
    ],
)

scrooge_scala_library(
    name = "scroogebarejar2",
    visibility = ["//visibility:public"],
    deps = [
        "//test/src/main/scala/scalarules/test/twitter_scrooge/thrift/bare_jar_thrifts/bare_jar_2",
    ],
)

scrooge_scala_library(
    name = "bare_thrift_scrooge",
    visibility = ["//visibility:public"],
    exports = [
        ":scroogebarejar1",
        ":scroogebarejar2",
    ],
    deps = [
        "//test/src/main/scala/scalarules/test/twitter_scrooge/thrift/bare_jar_thrifts",
    ],
)

scala_library(
    name = "justscrooge1",
    srcs = ["JustScrooge1.scala"],
    exports = [":scrooge1"],
    deps = [":scrooge1"],
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
    exports = [":scrooge3"],
    deps = [":scrooge3"],
)

scala_library(
    name = "justscrooge3_import",
    srcs = ["JustScrooge3.scala"],
    deps = [
        "//test/src/main/scala/scalarules/test/twitter_scrooge/thrift/thrift2/thrift3:thrift3_import",
    ],
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
    main_class = "scalarules.test.twitter_scrooge.Twodeep",
    visibility = ["//visibility:public"],
    deps = [":twodeep"],
)

scala_binary(
    name = "justscrooge2b_binary",
    main_class = "scalarules.test.twitter_scrooge.JustScrooge2b",
    visibility = ["//visibility:public"],
    deps = [":justscrooge2b"],
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
    main_class = "scalarules.test.twitter_scrooge.JustScrooge1",
    visibility = ["//visibility:public"],
    deps = [":allscrooges"],
)

scala_library(
    name = "barethriftslib",
    srcs = ["BareThrifts.scala"],
    deps = [":bare_thrift_scrooge"],
)

scala_binary(
    name = "barethrifts",
    main_class = "scalarules.test.twitter_scrooge.BareThrifts",
    visibility = ["//visibility:public"],
    deps = [":barethriftslib"],
)

sh_test(
    name = "libthrift2_a_not_on_classpath",
    srcs = ["grep.sh"],
    args = [
        "libthrift2_a",
        "$(location :justscrooges)",
    ],
    data = [":justscrooges"],
)

sh_test(
    name = "java_jar_not_on_classpath",
    srcs = ["grep.sh"],
    args = [
        "_java.jar",
        "$(location :justscrooges)",
    ],
    data = [":justscrooges"],
)

twitter_scrooge_test_suite()

scrooge_scala_library(
    name = "scrooge_service",
    deps = [
        "//test/src/main/scala/scalarules/test/twitter_scrooge/thrift:thrift_service",
    ],
)
