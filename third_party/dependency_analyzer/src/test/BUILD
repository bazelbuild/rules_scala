licenses(["notice"])  # 3-clause BSD

load("//scala:scala.bzl", "scala_junit_test", "scala_test")

scala_test(
    name = "strict_deps_test",
    size = "small",
    srcs = [
        "io/bazel/rulesscala/dependencyanalyzer/StrictDepsTest.scala",
    ],
    jvm_flags = [
        "-Dplugin.jar.location=$(location //third_party/dependency_analyzer/src/main:dependency_analyzer)",
        "-Dguava.jar.location=$(location @com_google_guava_guava_21_0_with_file//jar)",
        "-Dapache.commons.jar.location=$(location @org_apache_commons_commons_lang_3_5_without_file//:linkable_org_apache_commons_commons_lang_3_5_without_file)",
    ],
    unused_dependency_checker_mode = "off",
    deps = [
        "//third_party/dependency_analyzer/src/main:dependency_analyzer",
        "//third_party/utils/src/test:test_util",
        "@com_google_guava_guava_21_0_with_file//jar",
        "@org_apache_commons_commons_lang_3_5_without_file//:linkable_org_apache_commons_commons_lang_3_5_without_file",
    ],
)

scala_test(
    name = "unused_dependency_checker_test",
    size = "small",
    srcs = [
        "io/bazel/rulesscala/dependencyanalyzer/UnusedDependencyCheckerTest.scala",
    ],
    jvm_flags = [
        "-Dplugin.jar.location=$(location //third_party/dependency_analyzer/src/main:dependency_analyzer)",
        "-Dapache.commons.jar.location=$(location @org_apache_commons_commons_lang_3_5_without_file//:linkable_org_apache_commons_commons_lang_3_5_without_file)",
    ],
    unused_dependency_checker_mode = "off",
    deps = [
        "//third_party/dependency_analyzer/src/main:dependency_analyzer",
        "//third_party/utils/src/test:test_util",
        "@org_apache_commons_commons_lang_3_5_without_file//:linkable_org_apache_commons_commons_lang_3_5_without_file",
    ],
)
