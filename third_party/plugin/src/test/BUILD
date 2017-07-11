licenses(["notice"])  # 3-clause BSD

load("//scala:scala.bzl", "scala_junit_test")

scala_junit_test(
        name = "dependency_analyzer_test",
        srcs = ["io/bazel/rulesscala/dependencyanalyzer/DependencyAnalyzerSpec.scala",
                "io/bazel/rulesscala/dependencyanalyzer/TestUtil.scala"],
        suffixes = ["Test"],
        size = "small",
        deps = ["//third_party/plugin/src/main:dependency_analyzer",
                "@io_get_coursier_coursier_cache//jar",
                "@io_get_coursier_coursier//jar",
                "@org_scalaz_scalaz_concurrent_2_11//jar",
                "//external:io_bazel_rules_scala/dependency/scalaz/scalaz_effect",
                "//external:io_bazel_rules_scala/dependency/scalaz/scalaz_core",
                "//external:io_bazel_rules_scala/dependency/scala/scala_xml",
                "//external:io_bazel_rules_scala/dependency/scala/scala_compiler",
                "//external:io_bazel_rules_scala/dependency/scala/scala_library",
                ],
        jvm_flags = ["-Dplugin.jar.location=$(location //third_party/plugin/src/main:dependency_analyzer)",
                     "-Dscala.library.location=$(location //external:io_bazel_rules_scala/dependency/scala/scala_library)"],
)