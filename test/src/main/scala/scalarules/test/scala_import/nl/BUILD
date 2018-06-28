load("//scala:scala.bzl", "scala_library", "scala_specs2_junit_test")
load("//scala:scala_import.bzl", "scala_import")

#Many jars
scala_import(
    name = "scala_import_never_link",
    jars = [
        "scala_import_never_link.jar"
    ],
    neverlink = True,
)

scala_specs2_junit_test(
    name = "scala_import_never_link_test",
    size = "small",
    srcs = ["ScalaImportNeverLinkTest.scala"],
    suffixes = ["Test"],
    deps = [":scala_import_never_link"],
)