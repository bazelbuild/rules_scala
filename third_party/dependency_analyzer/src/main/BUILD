load("//scala:scala.bzl", "scala_library_for_plugin_bootstrapping")
load("//scala:scala_cross_version_select.bzl", "select_for_scala_version")

scala_library_for_plugin_bootstrapping(
    name = "dependency_analyzer",
    srcs = [
        "io/bazel/rulesscala/dependencyanalyzer/DependencyAnalyzerSettings.scala",
        "io/bazel/rulesscala/dependencyanalyzer/OptionsParser.scala",
    ] + select_for_scala_version(
        any_2 = [
            "io/bazel/rulesscala/dependencyanalyzer/AstUsedJarFinder.scala",
            "io/bazel/rulesscala/dependencyanalyzer/DependencyAnalyzer.scala",
            "io/bazel/rulesscala/dependencyanalyzer/HighLevelCrawlUsedJarFinder.scala",
        ],
        any_3 = [
            "io/bazel/rulesscala/dependencyanalyzer3/AstUsedJarFinder.scala",
            "io/bazel/rulesscala/dependencyanalyzer3/DependencyAnalyzer.scala",
            "io/bazel/rulesscala/dependencyanalyzer3/HighLevelCrawlUsedJarFinder.scala",
        ],
        before_2_12_13 = [
            "io/bazel/rulesscala/dependencyanalyzer/Reporter.scala",
        ],
        between_2_12_13_and_3 = [
            "io/bazel/rulesscala/dependencyanalyzer/Reporter213.scala",
        ],
    ),
    build_ijar = False,
    resources = select_for_scala_version(
        any_2 = ["resources/scalac-plugin.xml"],
        any_3 = ["resources/plugin.properties"],
    ),
    visibility = ["//visibility:public"],
    deps = [
        ":scala_version",
        "//scala/private/toolchain_deps:scala_compile_classpath",
        "//src/java/io/bazel/rulesscala/scalac/reporter",
    ],
)

scala_library_for_plugin_bootstrapping(
    name = "scala_version",
    srcs = select_for_scala_version(
        any_2 = ["io/bazel/rulesscala/dependencyanalyzer/ScalaVersion.scala"],
        any_3 = ["io/bazel/rulesscala/dependencyanalyzer3/ScalaVersion.scala"],
    ),
    # As this contains macros we shouldn't make an ijar
    build_ijar = False,
    resources = ["resources/scalac-plugin.xml"],
    visibility = ["//visibility:public"],
    deps = [
        "//scala/private/toolchain_deps:scala_compile_classpath",
    ],
)
