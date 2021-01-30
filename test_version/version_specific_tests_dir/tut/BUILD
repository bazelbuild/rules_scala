load("@io_bazel_rules_scala//scala:scala.bzl", "scala_library")

scala_library(
    name = "test_dep",
    srcs = ["TestDep.scala"],
)

#TODO - uncomment once tut repo flakiness is resolved
#scala_tut_doc(
#    name = "some_example",
#    src = "SomeExample.md",
#    deps = [":test_dep"],
#)
