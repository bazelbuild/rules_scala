load("//scala:scala.bzl", "scala_macro_library", "scala_test")

scala_macro_library(
    name = "A",
    srcs = ["A.scala"],
)

scala_test(
    name = "EchoMacroSettings",
    srcs = ["EchoMacroSettings.scala"],
    scalacopts = [
        # The macro settings are used in the test itself.
        "-Xmacro-settings:name=a,b,c,d",
        "-Xmacro-settings:hobby=basketball,soccer",
    ],
    deps = [
        ":A",
    ],
)
