licenses(["notice"])  # 3-clause BSD

load("//scala:scala.bzl", "scala_library_for_plugin_bootstrapping")

scala_library_for_plugin_bootstrapping(
    name = "dependency_analyzer",
    srcs = [
        "io/bazel/rulesscala/dependencyanalyzer/DependencyAnalyzer.scala",
        "io/bazel/rulesscala/dependencyanalyzer/DependencyAnalyzerSettings.scala",
        "io/bazel/rulesscala/dependencyanalyzer/HighLevelCrawlUsedJarFinder.scala",
        "io/bazel/rulesscala/dependencyanalyzer/OptionsParser.scala",
    ],
    resources = ["resources/scalac-plugin.xml"],
    visibility = ["//visibility:public"],
    deps = [
        "//external:io_bazel_rules_scala/dependency/scala/scala_compiler",
        "//external:io_bazel_rules_scala/dependency/scala/scala_reflect",
    ],
)
