load("//scala/scalafmt:scala_with_scalafmt.bzl", "scala_binary", "scala_library", "scala_test")

### scala_binary ###
scala_binary(
    name = "formatted-binary",
    srcs = ["formatted.scala"],
    format = True,
    main_class = "scalarules.test.scalafmt.Format",
)

scala_binary(
    name = "unformatted-binary",
    srcs = ["unformatted.scala"],
    format = True,
    main_class = "scalarules.test.scalafmt.Format",
)

### scala_library ###
scala_library(
    name = "formatted-library",
    srcs = ["formatted.scala"],
    format = True,
)

scala_library(
    name = "unformatted-library",
    srcs = ["unformatted.scala"],
    format = True,
)

### scala_test ###
scala_test(
    name = "formatted-test",
    srcs = ["formatted-test.scala"],
    format = True,
)

scala_test(
    name = "unformatted-test",
    srcs = ["unformatted-test.scala"],
    format = True,
)
