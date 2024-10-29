load(
    "scalafmt_rules.bzl",
    "scalafmt_scala_binary",
    "scalafmt_scala_library",
    "scalafmt_scala_test",
)

filegroup(
    name = "scala2-conf",
    srcs = [".scalafmt2.conf"],
)

filegroup(
    name = "scala3-conf",
    srcs = [".scalafmt3.conf"],
)

scalafmt_scala_library(
    name = "unformatted-library2",
    srcs = ["unformatted/unformatted-library2.scala"],
    config = ":scala2-conf",
    format = True,
    scala_version = "2.13.15",
)

scalafmt_scala_library(
    name = "formatted-library2",
    srcs = ["formatted/formatted-library2.scala"],
    config = ":scala2-conf",
    format = True,
    scala_version = "2.13.15",
)

scalafmt_scala_library(
    name = "unformatted-library3",
    srcs = ["unformatted/unformatted-library3.scala"],
    config = ":scala3-conf",
    format = True,
    scala_version = "3.3.4",
)

scalafmt_scala_library(
    name = "formatted-library3",
    srcs = ["formatted/formatted-library3.scala"],
    config = ":scala3-conf",
    format = True,
    scala_version = "3.3.4",
)

scalafmt_scala_binary(
    name = "unformatted-binary2",
    srcs = ["unformatted/unformatted-binary2.scala"],
    config = ":scala2-conf",
    format = True,
    main_class = "UnformattedBinary",
    scala_version = "2.12.20",
)

scalafmt_scala_binary(
    name = "formatted-binary2",
    srcs = ["formatted/formatted-binary2.scala"],
    config = ":scala2-conf",
    format = True,
    main_class = "UnformattedBinary",
    scala_version = "2.12.20",
)

scalafmt_scala_binary(
    name = "unformatted-binary3",
    srcs = ["unformatted/unformatted-binary3.scala"],
    config = ":scala3-conf",
    format = True,
    main_class = "UnformattedBinary",
    scala_version = "3.2.2",
)

scalafmt_scala_binary(
    name = "formatted-binary3",
    srcs = ["formatted/formatted-binary3.scala"],
    config = ":scala3-conf",
    format = True,
    main_class = "UnformattedBinary",
    scala_version = "3.2.2",
)

scalafmt_scala_test(
    name = "unformatted-test2",
    srcs = ["unformatted/unformatted-test2.scala"],
    config = ":scala2-conf",
    format = True,
    scala_version = "2.12.20",
)

scalafmt_scala_test(
    name = "formatted-test2",
    srcs = ["formatted/formatted-test2.scala"],
    config = ":scala2-conf",
    format = True,
    scala_version = "2.12.20",
)

#default scala version is 3.1.3
scalafmt_scala_test(
    name = "unformatted-test3",
    srcs = ["unformatted/unformatted-test3.scala"],
    config = ":scala3-conf",
    format = True,
)

scalafmt_scala_test(
    name = "formatted-test3",
    srcs = ["formatted/formatted-test3.scala"],
    config = ":scala3-conf",
    format = True,
)
