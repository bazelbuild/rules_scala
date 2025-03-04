load("@rules_scala//scala:scala.bzl", "scala_library", "scala_test")

scala_library(
    name = "hello",
    srcs = ["Hello.scala"],
)

scala_test(
    name = "hello-test",
    srcs = ["HelloTest.scala"],
    deps = [":hello"],
)
