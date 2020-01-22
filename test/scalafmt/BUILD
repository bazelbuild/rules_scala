load(
    "//test/scalafmt:phase_scalafmt_test.bzl",
    "scalafmt_scala_binary",
    "scalafmt_scala_library",
    "scalafmt_scala_test",
)

filegroup(
    name = "custom-conf",
    srcs = [".scalafmt.conf"],
    visibility = ["//visibility:public"],
)

### scala_binary ###
scalafmt_scala_binary(
    name = "formatted-binary",
    srcs = ["formatted/formatted.scala"],
    format = True,
    main_class = "scalarules.test.scalafmt.Format",
)

scalafmt_scala_binary(
    name = "unformatted-binary",
    srcs = ["unformatted/unformatted.scala"],
    format = True,
    main_class = "scalarules.test.scalafmt.Format",
)

### scala_library ###
scalafmt_scala_library(
    name = "formatted-library",
    srcs = ["formatted/formatted.scala"],
    format = True,
)

scalafmt_scala_library(
    name = "unformatted-library",
    srcs = ["unformatted/unformatted.scala"],
    format = True,
)

### scala_test ###
scalafmt_scala_test(
    name = "formatted-test",
    srcs = ["formatted/formatted-test.scala"],
    format = True,
)

scalafmt_scala_test(
    name = "unformatted-test",
    srcs = ["unformatted/unformatted-test.scala"],
    format = True,
)

### custom config ###
scalafmt_scala_library(
    name = "formatted-custom-conf",
    srcs = ["formatted/formatted-custom-conf.scala"],
    config = ":custom-conf",
    format = True,
)

scalafmt_scala_library(
    name = "unformatted-custom-conf",
    srcs = ["unformatted/unformatted-custom-conf.scala"],
    config = ":custom-conf",
    format = True,
)
