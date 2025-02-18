load(
    "//scala:scala.bzl",
    "scala_library",
    "scala_macro_library",
    "scala_test",
)

scala_test(
    name = "JarStampingTest",
    srcs = ["JarStampingTest.scala"],
    deps = [
        ":any_scala_library",
        ":any_scala_macro_library",
    ],
)

scala_library(
    name = "any_scala_library",
    srcs = ["ClassFromLibrary.scala"],
)

scala_macro_library(
    name = "any_scala_macro_library",
    srcs = ["ClassFromMacroLibrary.scala"],
)
