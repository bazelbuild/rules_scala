load("//scala:scala.bzl", "scala_library", "scala_specs2_junit_test")

scala_library(
    name = "only_scala_sources",
    srcs = [
        "SomeScalaWithDeps.scala",
    ],
    unused_dependency_checker_ignored_targets = [
        ":scala_ignored_unused_dep",
    ],
    unused_dependency_checker_mode = "warn",  # override toolchain error mode for the test to pass
    deps = [
        ":scala_dep",
        ":scala_ignored_unused_dep",
        ":scala_unused_dep",
    ],
)

scala_library(
    name = "mixed_sources",
    srcs = [
        "SomeJava.java",
        "SomeScalaWithDeps.scala",
    ],
    unused_dependency_checker_ignored_targets = [
        ":scala_ignored_unused_dep",
    ],
    deps = [
        ":scala_dep",
        ":scala_ignored_unused_dep",
        ":scala_unused_dep",
    ],
)

scala_library(
    name = "scala_dep",
    srcs = ["ScalaDep.scala"],
)

scala_library(
    name = "scala_unused_dep",
    srcs = ["AnotherScalaDep.scala"],
)

scala_library(
    name = "scala_ignored_unused_dep",
    srcs = ["IgnoredScalaDep.scala"],
)

scala_specs2_junit_test(
    name = "sdeps_test",
    srcs = ["SdepsTest.scala"],
    resources = [
        ":mixed_sources.sdeps",
        ":only_scala_sources.sdeps",
    ],
    suffixes = ["Test"],
    deps = [
        "//src/java/io/bazel/rulesscala/scalac/reporter:scala_deps_java_proto",
        "@com_google_protobuf//:protobuf_java",
    ],
)
