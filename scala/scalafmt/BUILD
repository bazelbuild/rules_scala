load("//scala:scala.bzl", "scala_binary")
load("//scala/scalafmt/toolchain:toolchain.bzl", "export_scalafmt_deps", "scalafmt_toolchain")
load("@io_bazel_rules_scala//scala:providers.bzl", "declare_deps_provider")

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

load(
    "//scala/scalafmt:phase_scalafmt_ext.bzl",
    "scalafmt_singleton",
)

scalafmt_singleton(
    name = "phase_scalafmt",
    visibility = ["//visibility:public"],
)

declare_deps_provider(
    name = "scalafmt_classpath_provider",
    deps_id = "scalafmt_classpath",
    visibility = ["//visibility:public"],
    deps = [
        "@com_geirsson_metaconfig_core",
        "@org_scalameta_parsers",
        "@org_scalameta_scalafmt_core",
    ],
)

scalafmt_toolchain(
    name = "scalafmt_toolchain_impl",
    dep_providers = [
        ":scalafmt_classpath_provider",
    ],
    visibility = ["//visibility:public"],
)

toolchain(
    name = "scalafmt_toolchain",
    toolchain = ":scalafmt_toolchain_impl",
    toolchain_type = "//scala/scalafmt/toolchain:scalafmt_toolchain_type",
    visibility = ["//visibility:public"],
)

export_scalafmt_deps(
    name = "scalafmt_classpath",
    deps_id = "scalafmt_classpath",
    visibility = ["//visibility:public"],
)
