load("//scala:scala.bzl", "scala_library", "scala_macro_library")

scala_library(
    name = "incorrect-macro",
    srcs = ["IdentityMacro.scala"],
)

scala_macro_library(
    name = "correct-macro",
    srcs = ["IdentityMacro.scala"],
)

scala_library(
    name = "incorrect-macro-user",
    srcs = ["MacroUser.scala"],
    tags = ["manual"],
    deps = [":incorrect-macro"],
)

scala_library(
    name = "correct-macro-user",
    srcs = ["MacroUser.scala"],
    deps = [":correct-macro"],
)
