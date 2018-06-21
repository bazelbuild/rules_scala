licenses(["notice"])  # 3-clause BSD

load("//scala:scala.bzl", "scala_library_for_plugin_bootstrapping")

scala_library_for_plugin_bootstrapping(
    name = "dependency_analyzer",
    srcs = [
        "io/bazel/rulesscala/dependencyanalyzer/DependencyAnalyzer.scala",
    ],
    resources = ["resources/scalac-plugin.xml"],
    visibility = ["//visibility:public"],
)
