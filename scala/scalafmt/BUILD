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
    srcs = ["scalafmt/ScalafmtRunner.scala"],
    main_class = "io.bazel.rules_scala.scalafmt.ScalafmtRunner",
    visibility = ["//visibility:public"],
    deps = [
        "//external:io_bazel_rules_scala/scalafmt/argparse4j",
        "//src/java/io/bazel/rulesscala/worker",
        "@com_geirsson_metaconfig_core_2_11",
        "@org_scalameta_parsers_2_11",
        "@org_scalameta_scalafmt_core_2_11",
    ],
)

load(
    "//scala/scalafmt:phase_scalafmt_ext.bzl",
    "scalafmt_singleton",
)

scalafmt_singleton(
    name = "phase_scalafmt",
    visibility = ["//visibility:public"],
)
