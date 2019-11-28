licenses(["notice"])  # 3-clause BSD

load("//scala:scala.bzl", "scala_junit_test", "scala_test")

scala_junit_test(
    name = "dependency_analyzer_test",
    size = "small",
    srcs = [
        "io/bazel/rulesscala/dependencyanalyzer/DependencyAnalyzerTest.scala",
    ],
    jvm_flags = [
        "-Dplugin.jar.location=$(location //third_party/dependency_analyzer/src/main:dependency_analyzer)",
        "-Dscala.library.location=$(location //external:io_bazel_rules_scala/dependency/scala/scala_library)",
        "-Dguava.jar.location=$(location @maven//:com_google_guava_guava)",
        "-Dapache.commons.jar.location=$(location @org_apache_commons_commons_lang_3_5_without_file//:linkable_org_apache_commons_commons_lang_3_5_without_file)",
    ],
    suffixes = ["Test"],
    unused_dependency_checker_mode = "off",
    deps = [
        "//external:io_bazel_rules_scala/dependency/scala/scala_compiler",
        "//external:io_bazel_rules_scala/dependency/scala/scala_library",
        "//external:io_bazel_rules_scala/dependency/scala/scala_reflect",
        "//third_party/dependency_analyzer/src/main:dependency_analyzer",
        "//third_party/utils/src/test:test_util",
        "@maven//:com_google_guava_guava",
        "@org_apache_commons_commons_lang_3_5_without_file//:linkable_org_apache_commons_commons_lang_3_5_without_file",
    ],
)
