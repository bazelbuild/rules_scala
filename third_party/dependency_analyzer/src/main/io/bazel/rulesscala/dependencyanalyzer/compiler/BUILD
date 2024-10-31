load("@io_bazel_rules_scala//scala:scala_cross_version_select.bzl", "select_for_scala_version")
load("//scala:scala.bzl", "scala_library_for_plugin_bootstrapping")

scala_library_for_plugin_bootstrapping(
    name = "dep_reporting_compiler",
    srcs = ["@scala_compiler_sources//:src"],
    scalac_jvm_flags = ["-Xmx128M"],  # fixme - workaround for a failing test
    scalacopts = select_for_scala_version(
        any_3 = [
            # Silence migration warnings when using Scala 3.4+
            "-Wconf:msg=Alphanumeric method .* is not declared infix:s",
            "-Wconf:cat=deprecation:s",
        ],
    ),
    visibility = ["//visibility:public"],
    deps = ["//scala/private/toolchain_deps:scala_compile_classpath"],
)
