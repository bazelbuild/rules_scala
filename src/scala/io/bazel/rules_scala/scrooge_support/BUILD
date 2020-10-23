load("//scala:scala.bzl", "scala_library")

scala_library(
    name = "compiler",
    srcs = [
        "Compiler.scala",
        "FocusedZipImporter.scala",
    ],
    # util_core is still needed as a dep for older versions of scrooge
    unused_dependency_checker_mode = "off",
    visibility = ["//visibility:public"],
    deps = [
        "//twitter_scrooge:compiler_classpath",
    ],
)
