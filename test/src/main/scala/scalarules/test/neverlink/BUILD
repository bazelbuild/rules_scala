load("//scala:scala.bzl", "scala_library", "scala_test")

scala_library(
    name = "LinkableA",
    srcs = ["A.scala"],
)

scala_library(
    name = "NonLinkableB",
    srcs = ["B.scala"],
    neverlink = True,
)

scala_library(
    name = "intermediate_export",
    exports = [
        ":LinkableA",
        ":NonLinkableB",
    ],
)

scala_test(
    name = "NeverlinkTest",
    srcs = ["NeverlinkTest.scala"],
    runtime_deps = [":intermediate_export"],
)
