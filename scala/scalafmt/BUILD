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
        "//src/java/io/bazel/rulesscala/worker",
        "@com_geirsson_metaconfig_core",
        "@org_scalameta_parsers",
        "@org_scalameta_scalafmt_core",
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
