load("//scala:scala.bzl", "scala_test")

licenses(["notice"])  # 3-clause BSD

common_jvm_flags = [
    "-Dplugin.jar.location=$(execpath //third_party/dependency_analyzer/src/main:dependency_analyzer)",
    "-Dscala.library.location=$(rootpath @io_bazel_rules_scala_scala_library)",
    "-Dscala.reflect.location=$(rootpath @io_bazel_rules_scala_scala_reflect)",
]

scala_test(
    name = "ast_used_jar_finder_test",
    size = "small",
    srcs = [
        "io/bazel/rulesscala/dependencyanalyzer/AstUsedJarFinderTest.scala",
    ],
    jvm_flags = common_jvm_flags,
    deps = [
        "@io_bazel_rules_scala_scala_compiler",
        "@io_bazel_rules_scala_scala_library",
        "@io_bazel_rules_scala_scala_reflect",
        "//src/java/io/bazel/rulesscala/io_utils",
        "//third_party/dependency_analyzer/src/main:dependency_analyzer",
        "//third_party/dependency_analyzer/src/main:scala_version",
        "//third_party/utils/src/test:test_util",
    ],
)

scala_test(
    name = "scala_version_test",
    size = "small",
    srcs = [
        "io/bazel/rulesscala/dependencyanalyzer/ScalaVersionTest.scala",
    ],
    deps = [
        "@io_bazel_rules_scala_scala_library",
        "@io_bazel_rules_scala_scala_reflect",
        "//third_party/dependency_analyzer/src/main:scala_version",
    ],
)

scala_test(
    name = "scalac_dependency_test",
    size = "small",
    srcs = [
        "io/bazel/rulesscala/dependencyanalyzer/ScalacDependencyTest.scala",
    ],
    jvm_flags = common_jvm_flags,
    unused_dependency_checker_mode = "off",
    deps = [
        "@io_bazel_rules_scala_scala_compiler",
        "@io_bazel_rules_scala_scala_library",
        "@io_bazel_rules_scala_scala_reflect",
        "//src/java/io/bazel/rulesscala/io_utils",
        "//third_party/dependency_analyzer/src/main:dependency_analyzer",
        "//third_party/utils/src/test:test_util",
    ],
)

scala_test(
    name = "strict_deps_test",
    size = "small",
    srcs = [
        "io/bazel/rulesscala/dependencyanalyzer/StrictDepsTest.scala",
    ],
    jvm_flags = common_jvm_flags + [
        "-Dguava.jar.location=$(rootpath @com_google_guava_guava_21_0_with_file//jar)",
        "-Dapache.commons.jar.location=$(location @org_apache_commons_commons_lang_3_5_without_file//:linkable_org_apache_commons_commons_lang_3_5_without_file)",
    ],
    unused_dependency_checker_mode = "off",
    deps = [
        "@io_bazel_rules_scala_scala_compiler",
        "@io_bazel_rules_scala_scala_library",
        "@io_bazel_rules_scala_scala_reflect",
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
        "@io_bazel_rules_scala_scala_compiler",
        "@io_bazel_rules_scala_scala_library",
        "@io_bazel_rules_scala_scala_reflect",
        "//third_party/dependency_analyzer/src/main:dependency_analyzer",
        "//third_party/utils/src/test:test_util",
        "@org_apache_commons_commons_lang_3_5_without_file//:linkable_org_apache_commons_commons_lang_3_5_without_file",
    ],
)
