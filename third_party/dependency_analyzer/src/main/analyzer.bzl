load("//scala:scala.bzl", "scala_library_for_plugin_bootstrapping")
load(
    "//scala:scala_cross_version.bzl",
    "extract_major_version",
    "version_suffix",
)
load("@io_bazel_rules_scala_config//:config.bzl", "SCALA_VERSIONS")

def analyzer():
    for scala_version in SCALA_VERSIONS:
        _analyzer(scala_version)

def _analyzer(scala_version):
    if scala_version.startswith("2"):
        _analyzer_scala_2(scala_version)
    else:
        _analyzer_scala_3(scala_version)

def _analyzer_scala_3(scala_version):
    scala_library_for_plugin_bootstrapping(
        name = "dependency_analyzer" + version_suffix(scala_version),
        srcs = [
            "io/bazel/rulesscala/dependencyanalyzer3/DependencyAnalyzer.scala",
        ],
        resources = ["resources/plugin.properties"],
        visibility = ["//visibility:public"],
        deps = [
            "//scala/private/toolchain_deps:scala_compile_classpath",
        ],
    )

def _analyzer_scala_2(scala_version):
    scala_library_for_plugin_bootstrapping(
        name = "scala_version" + version_suffix(scala_version),
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

    scala_major_version = extract_major_version(scala_version)
    scala_minor_version = int(scala_version.replace(
        "%s." % scala_major_version,
        "",
    ))

    REPORTER_COMPATIBILITY_FOR_212 = scala_major_version == "2.12" and scala_minor_version >= 13

    REPORTER_COMPATIBILITY = "213" if (scala_major_version == "2.13" or REPORTER_COMPATIBILITY_FOR_212) else ""

    scala_library_for_plugin_bootstrapping(
        name = "dependency_analyzer" + version_suffix(scala_version),
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
            ":scala_version" + version_suffix(scala_version),
            "//scala/private/toolchain_deps:scala_compile_classpath",
            "//src/java/io/bazel/rulesscala/scalac:scalac_reporter" + version_suffix(scala_version),
        ],
    )
