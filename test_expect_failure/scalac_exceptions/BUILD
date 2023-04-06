load("//scala:scala.bzl", "scala_library", "scala_macro_library")

scala_macro_library(
    name = "bad_macro",
    srcs = ["BadMacro.scala"],
)

scala_library(
    name = "bad_macro_invocation",
    srcs = ["BadMacroInvocation.scala"],
    deps = [":bad_macro"],
)

scala_library(
    name = "stack_overflow_macro_invocation",
    srcs = ["StackOverflowMacroInvocation.scala"],
    deps = [":bad_macro"],
)