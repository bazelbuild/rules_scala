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

scala_library(
    name = "macro-dependency",
    srcs = ["MacroDependency.scala"],
)

scala_macro_library(
    name = "macro-with-dependencies",
    srcs = ["MacroWithDependencies.scala"],
    deps = [":macro-dependency"],
)

scala_library(
    name = "macro-with-dependencies-user",
    srcs = ["MacroWithDependenciesUser.scala"],
    # Without this, `:macro-dependency` will be flagged as an unused dependency. But we want to test that despite it
    # appearing before `:macro-with-dependencies` in `deps`, its runtime JAR is included before its compile JAR in the
    # compile classpath
    unused_dependency_checker_mode = "off",
    deps = [
        ":macro-dependency",
        ":macro-with-dependencies",
    ],
)
