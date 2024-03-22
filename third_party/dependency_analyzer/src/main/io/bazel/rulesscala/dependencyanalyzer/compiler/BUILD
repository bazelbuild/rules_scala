load("//scala:scala.bzl", "scala_library_for_plugin_bootstrapping")
load("@io_bazel_rules_scala_config//:config.bzl", "SCALA_VERSIONS")
load("@io_bazel_rules_scala//scala:scala_cross_version.bzl", "version_suffix")

scala_library_for_plugin_bootstrapping(
    name = "dep_reporting_compiler",
    srcs = select({
        "@io_bazel_rules_scala_config//:scala_version" + version_suffix(v): ["@scala_compiler_source%s//:src" % version_suffix(v)]
        for v in SCALA_VERSIONS
    }),
    scalac_jvm_flags = ["-Xmx128M"],  # fixme - workaround for a failing test
    visibility = ["//visibility:public"],
    deps = ["//scala/private/toolchain_deps:scala_compile_classpath"],
)
