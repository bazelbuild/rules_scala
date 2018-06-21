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

scala_repl(
    name = "repl",
    deps = [":lib"],
)

scala_test(
    name = "test",
    srcs = ["Test.scala"],
)

scala_binary(
    name = "binary",
    srcs = ["ScalaBinary.scala"],
    main_class = "scala.test.crossbuild.ScalaBinary",
)

scala_macro_library(
    name = "macro",
    srcs = ["MacroTest.scala"],
)

scala_junit_test(
    name = "junit",
    srcs = ["JunitTests.scala"],
    suffixes = ["Test"],
    size = "small",
)
