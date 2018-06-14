load(
    "//scala:scala.bzl",
    "scala_library",
    "scala_repl",
)


scala_library(
    name = "lib",
    srcs = ["HelloWorldLib212.scala"],
    scalaworker = "@scala_2_12//:worker"
)

scala_library(
    name = "lib211",
    srcs = ["HelloWorldLib211.scala"],
)

scala_repl(
    name = "repl",
    deps = [":lib211"]
)
