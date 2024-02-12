load("@io_bazel_rules_scala//scala:scala.bzl", "scala_binary", "scala_library")

scala_library(
    name = "hello211",
    scala_version = "2.11.12",
    srcs = ["Hello211.scala"],
)

scala_library(
    name = "hello213",
    scala_version = "2.13.12",
    srcs = ["Hello213.scala"],
)

# scala 3.3.1 is default for this workspace
scala_binary(
    name = "main",
    srcs = ["Main.scala"],
    main_class = "hello",
    deps = [":hello211", ":hello213"],
)
