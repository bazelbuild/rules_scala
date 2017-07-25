licenses(["notice"])  # 3-clause BSD

load("//scala:scala.bzl", "scala_junit_test")

scala_junit_test(
        name = "dependency_analyzer_test",
        srcs = ["io/bazel/rulesscala/dependencyanalyzer/DependencyAnalyzerTest.scala",
                "io/bazel/rulesscala/dependencyanalyzer/TestUtil.scala"],
        suffixes = ["Test"],
        size = "small",
        deps = ["//third_party/plugin/src/main:dependency_analyzer",
                "//external:io_bazel_rules_scala/dependency/scala/scala_compiler",
                "//external:io_bazel_rules_scala/dependency/scala/scala_library",
                "@com_google_guava_guava_21_0//jar",
                "@org_apache_commons_commons_lang_3_5//jar"
                ],
        jvm_flags = ["-Dplugin.jar.location=$(location //third_party/plugin/src/main:dependency_analyzer)",
                     "-Dscala.library.location=$(location //external:io_bazel_rules_scala/dependency/scala/scala_library)",
                     "-Dguava.jar.location=$(location @com_google_guava_guava_21_0//jar)",
                     "-Dapache.commons.jar.location=$(location @org_apache_commons_commons_lang_3_5//jar)"],
)