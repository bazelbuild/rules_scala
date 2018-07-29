licenses(["notice"])  # 3-clause BSD

load("//scala:scala.bzl", "scala_library_for_plugin_bootstrapping")

scala_library_for_plugin_bootstrapping(
    name = "unused_dependency_checker",
    srcs = [
        "io/bazel/rulesscala/unuseddependencychecker/UnusedDependencyChecker.scala",
    ],
    resources = ["resources/scalac-plugin.xml"],
    visibility = ["//visibility:public"],
    deps = [
        "//external:io_bazel_rules_scala/dependency/scala/scala_compiler",
        "//external:io_bazel_rules_scala/dependency/scala/scala_reflect",
        "//third_party/utils/src/main:utils",
    ],
    exports = [
        "//third_party/utils/src/main:utils",
    ]
)
