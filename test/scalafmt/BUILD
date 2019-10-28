load("//scala/scalafmt:scala_with_scalafmt.bzl", "scala_binary", "scala_library", "scala_test")

### scala_binary ###
scala_binary(
    name = "formatted-binary",
    srcs = ["formatted.scala"],
    format = True,
    main_class = "test.scalafmt.FormatTest",
)

scala_binary(
    name = "unformatted-binary",
    srcs = ["unformatted.tmp.scala"],
    format = True,
    main_class = "test.scalafmt.FormatTest",
)

### scala_library ###
scala_library(
    name = "formatted-library",
    srcs = ["formatted.scala"],
    format = True,
)

scala_library(
    name = "unformatted-library",
    srcs = ["unformatted.tmp.scala"],
    format = True,
)

### scala_test ###
scala_test(
    name = "formatted-test",
    srcs = ["formatted.scala"],
    format = True,
)

scala_test(
    name = "unformatted-test",
    srcs = ["unformatted.tmp.scala"],
    format = True,
)

### utf8 encoding test ###
scala_library(
    name = "formatted-utf8-library",
    srcs = ["formatted-utf8.scala"],
    format = True,
)

scala_library(
    name = "unformatted-utf8-library",
    srcs = ["unformatted-utf8.tmp.scala"],
    format = True,
)
