load("//scala:scala.bzl", "scala_binary")
load("//scala:scala_cross_version.bzl", "version_suffix")
load("//scala/scalafmt/toolchain:toolchain.bzl", "export_scalafmt_deps")
load("//scala/scalafmt/toolchain:setup_scalafmt_toolchain.bzl", "setup_scalafmt_toolchains")
load("@io_bazel_rules_scala_config//:config.bzl", "SCALA_VERSION")
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

# Alias for backward compatibility:
alias(
    name = "scalafmt_toolchain",
    actual = "scalafmt_toolchain" + version_suffix(SCALA_VERSION),
)

export_scalafmt_deps(
    name = "scalafmt_classpath",
    deps_id = "scalafmt_classpath",
    visibility = ["//visibility:public"],
)
