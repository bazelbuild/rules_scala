load("@io_bazel_rules_scala//scala:scala.bzl", "scala_binary", "scala_library", "scala_test")

scala_library(
    name = "lib",
    srcs = ["Hello.scala"],
    deps = [],
)

scala_binary(
    name = "main",
    srcs = ["Main.scala"],
    main_class = "hello",
    deps = [":lib"],
)
