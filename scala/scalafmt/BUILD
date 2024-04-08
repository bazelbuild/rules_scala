load("//scala:scala.bzl", "scala_binary")
load("//scala:scala_cross_version.bzl", "version_suffix")
load("//scala/scalafmt/toolchain:toolchain.bzl", "export_scalafmt_deps", "scalafmt_toolchain")
load("@io_bazel_rules_scala//scala:providers.bzl", "declare_deps_provider")
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

declare_deps_provider(
    name = "scalafmt_classpath_provider",
    deps_id = "scalafmt_classpath",
    visibility = ["//visibility:public"],
    deps = [
        "@com_geirsson_metaconfig_core",
        "@org_scalameta_common",
        "@org_scalameta_parsers",
        "@org_scalameta_scalafmt_core",
        "@org_scalameta_scalameta",
        "@org_scalameta_trees",
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
    target_settings = ["@io_bazel_rules_scala_config//:scala_version" + version_suffix(SCALA_VERSION)],
    toolchain = ":scalafmt_toolchain_impl",
    toolchain_type = "//scala/scalafmt/toolchain:scalafmt_toolchain_type",
    visibility = ["//visibility:public"],
)

export_scalafmt_deps(
    name = "scalafmt_classpath",
    deps_id = "scalafmt_classpath",
    visibility = ["//visibility:public"],
)
