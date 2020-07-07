licenses(["notice"])  # 3-clause BSD

load("//scala:scala.bzl", "scala_library_for_plugin_bootstrapping")

scala_library_for_plugin_bootstrapping(
    name = "scala_version",
    srcs = [
        "io/bazel/rulesscala/dependencyanalyzer/ScalaVersion.scala",
    ],
    # As this contains macros we shouldn't make an ijar
    build_ijar = False,
    resources = ["resources/scalac-plugin.xml"],
    visibility = ["//visibility:public"],
    deps = [
        "//scala/private/toolchain_deps:scala_compile_classpath",
    ],
)

scala_library_for_plugin_bootstrapping(
    name = "dependency_analyzer",
    srcs = [
        "io/bazel/rulesscala/dependencyanalyzer/AstUsedJarFinder.scala",
        "io/bazel/rulesscala/dependencyanalyzer/DependencyAnalyzer.scala",
        "io/bazel/rulesscala/dependencyanalyzer/DependencyAnalyzerSettings.scala",
        "io/bazel/rulesscala/dependencyanalyzer/HighLevelCrawlUsedJarFinder.scala",
        "io/bazel/rulesscala/dependencyanalyzer/OptionsParser.scala",
    ],
    resources = ["resources/scalac-plugin.xml"],
    visibility = ["//visibility:public"],
    deps = [
        ":scala_version",
        "//scala/private/toolchain_deps:scala_compile_classpath",
    ],
)
