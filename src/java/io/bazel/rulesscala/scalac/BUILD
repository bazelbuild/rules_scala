load("//scala:scala_cross_version_select.bzl", "select_for_scala_version")
load("//src/java/io/bazel/rulesscala/scalac:definitions.bzl", "define_scalac", "define_scalac_bootstrap")

define_scalac()

define_scalac_bootstrap()

filegroup(
    name = "scalac_files",
    srcs = [
        "ScalacInvokerResults.java",
        "ScalacWorker.java",
    ] + select_for_scala_version(
        any_2 = glob(["scala_2/*.java"]),
        any_3 = glob(["scala_3/*.java"]),
    ),
    visibility = ["//visibility:public"],
)
