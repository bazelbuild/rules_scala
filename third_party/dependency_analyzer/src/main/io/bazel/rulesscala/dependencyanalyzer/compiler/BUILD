load("//scala:scala.bzl", "scala_library_for_plugin_bootstrapping")

scala_library_for_plugin_bootstrapping(
    name = "dep_reporting_compiler",
    srcs = ["@scala_compiler_sources//:src"],
    scalac_jvm_flags = ["-Xmx128M"],  # fixme - workaround for a failing test
    visibility = ["//visibility:public"],
    deps = ["//scala/private/toolchain_deps:scala_compile_classpath"],
)
