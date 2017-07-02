load("@io_bazel_rules_scala//scala:scala.bzl",
    "scala_binary",
    "scala_library",
    "scala_test",
    "scala_macro_library",
    "scala_specs2_junit_test",
    "scala_export_to_java",
    "scala_junit_test")

scala_junit_test(
        name = "dependency_analyzer_test",
        srcs = ["scala/io/github/retronym/dependencyanalyzer/DependencyAnalyzerSpec.scala",
                "scala/io/github/retronym/dependencyanalyzer/TestUtil.scala"],
        suffixes = ["Test"],
        size = "small",
        deps = ["//main:dependency_analyzer",
                "@io_get_coursier_coursier_cache//jar",
                "@io_get_coursier_coursier//jar",
                "@org_scalaz_scalaz_concurrent_2_11//jar",
                "//external:io_bazel_rules_scala/dependency/scalaz/scalaz_effect",
                "//external:io_bazel_rules_scala/dependency/scalaz/scalaz_core",
                "//external:io_bazel_rules_scala/dependency/scala/scala_xml",
                "//external:io_bazel_rules_scala/dependency/scala/scala_compiler",
                "//main:resources",
                "//test/resources:resources"
                ]
)