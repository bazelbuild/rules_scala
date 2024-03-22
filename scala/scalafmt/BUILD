load("//scala:scala.bzl", "scala_binary")
load("//scala/scalafmt/toolchain:toolchain.bzl", "export_scalafmt_deps")
load("//scala/scalafmt/toolchain:setup_scalafmt_toolchain.bzl", "setup_scalafmt_toolchains")
load(
    "//scala/scalafmt:phase_scalafmt_ext.bzl",
    "scalafmt_singleton",
)

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
    srcs = ["scalafmt/ScalafmtWorker.scala"],
    main_class = "io.bazel.rules_scala.scalafmt.ScalafmtWorker",
    visibility = ["//visibility:public"],
    deps = [
        ":scalafmt_classpath",
        "//src/java/io/bazel/rulesscala/worker",
    ],
)

scalafmt_singleton(
    name = "phase_scalafmt",
    visibility = ["//visibility:public"],
)

setup_scalafmt_toolchains()

export_scalafmt_deps(
    name = "scalafmt_classpath",
    deps_id = "scalafmt_classpath",
    visibility = ["//visibility:public"],
)
