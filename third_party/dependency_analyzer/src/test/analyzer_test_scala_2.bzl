load("//scala:scala.bzl", "scala_test")

def analyzer_tests_scala_2(version_suffix):
    common_jvm_flags = [
        "-Dplugin.jar.location=$(execpath //third_party/dependency_analyzer/src/main:dependency_analyzer%s)" % version_suffix,
        "-Dscala.library.location=$(rootpath @io_bazel_rules_scala_scala_library%s)" % version_suffix,
        "-Dscala.reflect.location=$(rootpath @io_bazel_rules_scala_scala_reflect%s)" % version_suffix,
    ]

    scala_test(
        name = "ast_used_jar_finder_test",
        size = "small",
        srcs = [
            "io/bazel/rulesscala/dependencyanalyzer/AstUsedJarFinderTest.scala",
        ],
        jvm_flags = common_jvm_flags,
        deps = [
            "//src/java/io/bazel/rulesscala/io_utils",
            "//third_party/dependency_analyzer/src/main:dependency_analyzer" + version_suffix,
            "//third_party/dependency_analyzer/src/main:scala_version" + version_suffix,
            "//third_party/utils/src/test:test_util",
            "@io_bazel_rules_scala_scala_compiler" + version_suffix,
            "@io_bazel_rules_scala_scala_library" + version_suffix,
            "@io_bazel_rules_scala_scala_reflect" + version_suffix,
        ],
    )

    scala_test(
        name = "scala_version_test",
        size = "small",
        srcs = [
            "io/bazel/rulesscala/dependencyanalyzer/ScalaVersionTest.scala",
        ],
        deps = [
            "//third_party/dependency_analyzer/src/main:scala_version" + version_suffix,
            "@io_bazel_rules_scala_scala_library" + version_suffix,
            "@io_bazel_rules_scala_scala_reflect" + version_suffix,
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
            "//src/java/io/bazel/rulesscala/io_utils",
            "//third_party/dependency_analyzer/src/main:dependency_analyzer" + version_suffix,
            "//third_party/utils/src/test:test_util",
            "@io_bazel_rules_scala_scala_compiler" + version_suffix,
            "@io_bazel_rules_scala_scala_library" + version_suffix,
            "@io_bazel_rules_scala_scala_reflect" + version_suffix,
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
            "//third_party/dependency_analyzer/src/main:dependency_analyzer" + version_suffix,
            "//third_party/utils/src/test:test_util",
            "@com_google_guava_guava_21_0_with_file//jar",
            "@io_bazel_rules_scala_scala_compiler" + version_suffix,
            "@io_bazel_rules_scala_scala_library" + version_suffix,
            "@io_bazel_rules_scala_scala_reflect" + version_suffix,
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
            "//third_party/dependency_analyzer/src/main:dependency_analyzer" + version_suffix,
            "//third_party/utils/src/test:test_util",
            "@io_bazel_rules_scala_scala_compiler" + version_suffix,
            "@io_bazel_rules_scala_scala_library" + version_suffix,
            "@io_bazel_rules_scala_scala_reflect" + version_suffix,
            "@org_apache_commons_commons_lang_3_5_without_file//:linkable_org_apache_commons_commons_lang_3_5_without_file",
        ],
    )
