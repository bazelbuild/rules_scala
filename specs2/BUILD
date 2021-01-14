load("@rules_java//java:defs.bzl", "java_import")

package(default_visibility = ["//visibility:public"])

java_import(
    name = "specs2",
    jars = [],
    exports = [
        "//testing/toolchain:specs2_classpath",
    ],
    deps = [
        "//scala/private/toolchain_deps:scala_library_classpath",
        "//scala/private/toolchain_deps:scala_xml",
    ],
)
