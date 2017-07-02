load("@io_bazel_rules_scala//scala:scala.bzl", "scala_library")

scala_library(
    name = "dependency_analyzer",
    srcs = ["scala/io/github/retronym/dependencyanalyzer/DependencyAnalyzer.scala",
            "scala_2_11/io/github/retronym/dependencyanalyzer/Compat.scala",
            ],
    resources = ["resources/scalac-plugin.xml"],
    visibility = ["//visibility:public"],
    deps = [
        "//external:io_bazel_rules_scala/dependency/scala/scala_compiler"
    ],
#    enable_dependency_analyzer = False
)

scala_library(
    name = "resources",
    resources = ["resources/toolbox.classpath"],
    visibility = ["//visibility:public"],
)