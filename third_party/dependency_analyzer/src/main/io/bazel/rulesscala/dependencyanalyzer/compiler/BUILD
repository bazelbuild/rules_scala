load("//scala:scala.bzl", "scala_library_for_plugin_bootstrapping")
load("@io_bazel_rules_scala_config//:config.bzl", "SCALA_VERSIONS")
load("@io_bazel_rules_scala//scala:scala_cross_version.bzl", "version_suffix")

[
    scala_library_for_plugin_bootstrapping(
        name = "dep_reporting_compiler" + version_suffix(version),
        srcs = ["@scala_compiler_source%s//:src" % version_suffix(version)],
        scalac_jvm_flags = ["-Xmx128M"],  # fixme - workaround for a failing test
        visibility = ["//visibility:public"],
        deps = ["//scala/private/toolchain_deps:scala_compile_classpath"],
    )
    for version in SCALA_VERSIONS
    if version.startswith("2")
]
