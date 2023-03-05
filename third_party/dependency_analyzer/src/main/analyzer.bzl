load("//scala:scala.bzl", "scala_library_for_plugin_bootstrapping")
load("@io_bazel_rules_scala_config//:config.bzl", "SCALA_MAJOR_VERSION", "SCALA_VERSION")

def analyzer():
    if SCALA_MAJOR_VERSION.startswith("2"):
        _analyzer_scala_2()
    else:
        _analyzer_scala_3()

def _analyzer_scala_3():
    scala_library_for_plugin_bootstrapping(
        name = "dependency_analyzer",
        srcs = [
            "io/bazel/rulesscala/dependencyanalyzer3/DependencyAnalyzer.scala",
        ],
        resources = ["resources/plugin.properties"],
        visibility = ["//visibility:public"],
        deps = [
            "//scala/private/toolchain_deps:scala_compile_classpath",
        ],
    )

def _analyzer_scala_2():
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

    SCALA_MINOR_VERSION = int(SCALA_VERSION.replace(
        "%s." % SCALA_MAJOR_VERSION,
        "",
    ))

    REPORTER_COMPATIBILITY_FOR_212 = SCALA_MAJOR_VERSION == "2.12" and SCALA_MINOR_VERSION >= 13

    REPORTER_COMPATIBILITY = "213" if (SCALA_MAJOR_VERSION == "2.13" or REPORTER_COMPATIBILITY_FOR_212) else ""

    scala_library_for_plugin_bootstrapping(
        name = "dependency_analyzer",
        srcs = [
            "io/bazel/rulesscala/dependencyanalyzer/AstUsedJarFinder.scala",
            "io/bazel/rulesscala/dependencyanalyzer/DependencyAnalyzer.scala",
            "io/bazel/rulesscala/dependencyanalyzer/DependencyAnalyzerSettings.scala",
            "io/bazel/rulesscala/dependencyanalyzer/HighLevelCrawlUsedJarFinder.scala",
            "io/bazel/rulesscala/dependencyanalyzer/OptionsParser.scala",
            "io/bazel/rulesscala/dependencyanalyzer/Reporter%s.scala" % REPORTER_COMPATIBILITY,
        ],
        resources = ["resources/scalac-plugin.xml"],
        visibility = ["//visibility:public"],
        deps = [
            ":scala_version",
            "//scala/private/toolchain_deps:scala_compile_classpath",
            "//src/java/io/bazel/rulesscala/scalac/reporter",
        ],
    )
