load("//scala:scala.bzl", "scala_library_for_plugin_bootstrapping")
load("//scala:scala_cross_version_select.bzl", "select_for_scala_version")

scala_library_for_plugin_bootstrapping(
    name = "dependency_analyzer",
    srcs = select_for_scala_version(
        any_2 = [
            "io/bazel/rulesscala/dependencyanalyzer/AstUsedJarFinder.scala",
            "io/bazel/rulesscala/dependencyanalyzer/DependencyAnalyzer.scala",
            "io/bazel/rulesscala/dependencyanalyzer/DependencyAnalyzerSettings.scala",
            "io/bazel/rulesscala/dependencyanalyzer/HighLevelCrawlUsedJarFinder.scala",
            "io/bazel/rulesscala/dependencyanalyzer/OptionsParser.scala",
        ],
        before_2_12_13 = [
            "io/bazel/rulesscala/dependencyanalyzer/Reporter.scala",
        ],
        between_2_12_13_and_3 = [
            "io/bazel/rulesscala/dependencyanalyzer/Reporter213.scala",
        ],
        since_3 = [
            "io/bazel/rulesscala/dependencyanalyzer3/DependencyAnalyzer.scala",
        ],
    ),
    resources = select_for_scala_version(
        any_2 = ["resources/scalac-plugin.xml"],
        any_3 = ["resources/plugin.properties"],
    ),
    visibility = ["//visibility:public"],
    deps = [
        "//scala/private/toolchain_deps:scala_compile_classpath",
    ] + select_for_scala_version(
        any_2 = [
            ":scala_version",
            "//src/java/io/bazel/rulesscala/scalac/reporter",
        ],
    ),
)

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
