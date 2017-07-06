load("//scala:scala.bzl", "scala_library", "scala_library_for_plugin_bootstrapping")

scala_library_for_plugin_bootstrapping(
    name = "dependency_analyzer",
    srcs = ["scala/io/github/retronym/dependencyanalyzer/DependencyAnalyzer.scala",
            "scala_2_11/io/github/retronym/dependencyanalyzer/Compat.scala",
            ],
    resources = ["resources/scalac-plugin.xml"],
    visibility = ["//visibility:public"],
    deps = [
        "//external:io_bazel_rules_scala/dependency/scala/scala_compiler"
    ],
)