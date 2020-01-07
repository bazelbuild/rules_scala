load(
    "//test/scalafmt:phase_scalafmt_test.bzl",
    "scalafmt_scala_binary",
    "scalafmt_scala_library",
    "scalafmt_scala_test",
)

### scala_binary ###
scalafmt_scala_binary(
    name = "formatted-binary",
    srcs = ["formatted.scala"],
    format = True,
    main_class = "scalarules.test.scalafmt.Format",
)

scalafmt_scala_binary(
    name = "unformatted-binary",
    srcs = ["unformatted.scala"],
    format = True,
    main_class = "scalarules.test.scalafmt.Format",
)

### scala_library ###
scalafmt_scala_library(
    name = "formatted-library",
    srcs = ["formatted.scala"],
    format = True,
)

scalafmt_scala_library(
    name = "unformatted-library",
    srcs = ["unformatted.scala"],
    format = True,
)

### scala_test ###
scalafmt_scala_test(
    name = "formatted-test",
    srcs = ["formatted-test.scala"],
    format = True,
)

scalafmt_scala_test(
    name = "unformatted-test",
    srcs = ["unformatted-test.scala"],
    format = True,
)
