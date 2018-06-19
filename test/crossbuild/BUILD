load(
    "//scala:scala.bzl",
    "scala_library",
    "scala_repl",
    "scala_test",
    "scala_binary",
    "scala_macro_library",
    "scala_junit_test"
)


scala_library(
    name = "lib",
    srcs = ["HelloWorldLib211.scala"],
)

scala_library(
    name = "lib212",
    srcs = ["HelloWorldLib212.scala"],
    scalaworker = "@scala_2_12",
)

scala_repl(
    name = "repl",
    deps = [":lib"],
)

scala_repl(
    name = "repl212",
    deps = [":lib212"],
    scalaworker = "@scala_2_12"
)

# TODO: scalatest not working with 2.12
scala_test(
    name = "test",
    srcs = ["Test.scala"],
)

scala_test(
    name = "test212",
    srcs = ["Test.scala"],
    scalaworker = "@scala_2_12",
)

scala_binary(
    name = "binary",
    srcs = ["ScalaBinary.scala"],
    main_class = "scala.test.crossbuild.ScalaBinary",
)

scala_binary(
    name = "binary212",
    srcs = ["ScalaBinary.scala"],
    main_class = "scala.test.crossbuild.ScalaBinary",
    scalaworker = "@scala_2_12"
)

scala_macro_library(
    name = "macro",
    srcs = ["MacroTest.scala"],
)

scala_macro_library(
    name = "macro212",
    srcs = ["MacroTest.scala"],
    scalaworker = "@scala_2_12"
)

# TODO: junit not working with 2.12
scala_junit_test(
    name = "junit",
    srcs = ["JunitTests.scala"],
    suffixes = ["Test"],
    size = "small",
)
