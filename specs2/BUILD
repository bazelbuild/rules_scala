load("@rules_java//java:defs.bzl", "java_import")
load("//specs2/toolchain:toolchain.bzl", "specs2_toolchain_deps")

package(default_visibility = ["//visibility:public"])

java_import(
    name = "specs2",
    jars = [],
    exports = [
        ":specs2_classpath",
    ],
    deps = [
        "@io_bazel_rules_scala//scala/private/toolchain_deps:parser_combinators",
        "@io_bazel_rules_scala//scala/private/toolchain_deps:scala_library_classpath",
        "@io_bazel_rules_scala//scala/private/toolchain_deps:scala_xml",
    ],
)

specs2_toolchain_deps(
    name = "specs2_classpath",
    provider_id = "specs2",
)

specs2_toolchain_deps(
    name = "specs2_junit_classpath",
    provider_id = "specs2_junit",
)
