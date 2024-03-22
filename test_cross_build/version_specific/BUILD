load("@io_bazel_rules_scala//scala:scala.bzl", "scala_library")

# A collection of arbitrarily chosen backward- and forward-incompatible code.
# This simply tests if the proper compiler is assigned, according to Scala version setting.

# What's new in 3.3
scala_library(
    name = "since_3_3",
    srcs = ["since_3_3.scala"],
    scala_version = "3.3.1",
)

scala_library(
    name = "before_3_3",
    srcs = ["before_3_3.scala"],
    scala_version = "3.2.1",
)

# What's new in 3.2
scala_library(
    name = "since_3_2",
    srcs = ["since_3_2.scala"],
    scala_version = "3.2.1",
)

scala_library(
    name = "before_3_2",
    srcs = ["before_3_2.scala"],
    scala_version = "3.1.0",
)

# What's new in 3.1
scala_library(
    name = "since_3_1",
    srcs = ["since_3_1.scala"],
    scala_version = "3.1.0",
)

scala_library(
    name = "scala_3_3",
    srcs = [
        "since_3_1.scala",
        "since_3_2.scala",
        "since_3_3.scala",
    ],
    scala_version = "3.3.1",
)

scala_library(
    name = "scala_3_2",
    srcs = [
        "before_3_3.scala",
        "since_3_1.scala",
        "since_3_2.scala",
    ],
    scala_version = "3.2.1",
)

scala_library(
    name = "scala_3_1",
    srcs = [
        "before_3_2.scala",
        "before_3_3.scala",
        "since_3_1.scala",
    ],
    scala_version = "3.1.0",
)
