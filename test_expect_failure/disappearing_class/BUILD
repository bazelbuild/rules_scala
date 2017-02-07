load("//scala:scala.bzl", "scala_binary", "scala_library", "scala_test", "scala_macro_library")

scala_library(
    name = "uses_class",
    srcs = ["UsesClass.scala"],
    deps = [":class_provider"],
)


scala_library(
    name = "class_provider",
    srcs = ["ClassProvider.scala"],
)
