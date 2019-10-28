load("//scala:scala.bzl", "scala_binary")

filegroup(
    name = "runner",
    srcs = ["private/format.template.sh"],
    visibility = ["//visibility:public"],
)

filegroup(
    name = "testrunner",
    srcs = ["private/format-test.template.sh"],
    visibility = ["//visibility:public"],
)

scala_binary(
    name = "scalafmt",
    srcs = glob(["scalafmt/ScalafmtRunner.scala"]),
    main_class = "io.bazel.rules_scala.scalafmt.ScalafmtRunner",
    visibility = ["//visibility:public"],
    deps = [
        "//src/java/io/bazel/rulesscala/worker",
        "@scalafmt//:com_geirsson_metaconfig_core_2_11",
        "@scalafmt//:net_sourceforge_argparse4j_argparse4j",
        "@scalafmt//:org_scalameta_parsers_2_11",
        "@scalafmt//:org_scalameta_scalafmt_core_2_11",
    ],
)

load(
    "//scala/scalafmt:ext.bzl",
    _add_phase_scalafmt_singleton = "add_phase_scalafmt_singleton",
)

_add_phase_scalafmt_singleton(
    name = "add_phase_scalafmt",
    visibility = ["//visibility:public"],
)
