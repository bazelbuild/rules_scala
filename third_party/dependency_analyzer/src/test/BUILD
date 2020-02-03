licenses(["notice"])  # 3-clause BSD

load("//scala:scala.bzl", "scala_junit_test", "scala_test")

common_jvm_flags = [
    "-Dplugin.jar.location=$(location //third_party/dependency_analyzer/src/main:dependency_analyzer)",
    "-Dscala.library.location=$(location //external:io_bazel_rules_scala/dependency/scala/scala_library)",
]

scala_test(
    name = "ast_used_jar_finder_test",
    size = "small",
    srcs = [
        "io/bazel/rulesscala/dependencyanalyzer/AstUsedJarFinderTest.scala",
    ],
    jvm_flags = common_jvm_flags,
    deps = [
        "//external:io_bazel_rules_scala/dependency/scala/scala_compiler",
        "//external:io_bazel_rules_scala/dependency/scala/scala_library",
        "//external:io_bazel_rules_scala/dependency/scala/scala_reflect",
        "//third_party/dependency_analyzer/src/main:dependency_analyzer",
        "//third_party/dependency_analyzer/src/main:scala_version",
        "//third_party/utils/src/test:test_util",
        "@scalac_rules_commons_io//jar",
    ],
)

scala_test(
    name = "scala_version_test",
    size = "small",
    srcs = [
        "io/bazel/rulesscala/dependencyanalyzer/ScalaVersionTest.scala",
    ],
    deps = [
        "//external:io_bazel_rules_scala/dependency/scala/scala_library",
        "//external:io_bazel_rules_scala/dependency/scala/scala_reflect",
        "//third_party/dependency_analyzer/src/main:scala_version",
    ],
)

scala_test(
    name = "strict_deps_test",
    size = "small",
    srcs = [
        "io/bazel/rulesscala/dependencyanalyzer/StrictDepsTest.scala",
    ],
    jvm_flags = common_jvm_flags + [
        "-Dguava.jar.location=$(location @com_google_guava_guava_21_0_with_file//jar)",
        "-Dapache.commons.jar.location=$(location @org_apache_commons_commons_lang_3_5_without_file//:linkable_org_apache_commons_commons_lang_3_5_without_file)",
    ],
    unused_dependency_checker_mode = "off",
    deps = [
        "//external:io_bazel_rules_scala/dependency/scala/scala_compiler",
        "//external:io_bazel_rules_scala/dependency/scala/scala_library",
        "//external:io_bazel_rules_scala/dependency/scala/scala_reflect",
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
    jvm_flags = common_jvm_flags + [
        "-Dapache.commons.jar.location=$(location @org_apache_commons_commons_lang_3_5_without_file//:linkable_org_apache_commons_commons_lang_3_5_without_file)",
    ],
    unused_dependency_checker_mode = "off",
    deps = [
        "//external:io_bazel_rules_scala/dependency/scala/scala_compiler",
        "//external:io_bazel_rules_scala/dependency/scala/scala_library",
        "//external:io_bazel_rules_scala/dependency/scala/scala_reflect",
        "//third_party/dependency_analyzer/src/main:dependency_analyzer",
        "//third_party/utils/src/test:test_util",
        "@org_apache_commons_commons_lang_3_5_without_file//:linkable_org_apache_commons_commons_lang_3_5_without_file",
    ],
)
