load("@io_bazel_rules_scala//scala:scala.bzl", "scala_test")
load("@io_bazel_rules_scala//scala:scala_cross_version_select.bzl", "select_for_scala_version")
load("@io_bazel_rules_scala_config//:config.bzl", "SCALA_MAJOR_VERSION", "SCALA_VERSION")
load("//scala:scala_cross_version.bzl", "version_suffix")

def tests():
    suffix = version_suffix(SCALA_VERSION)
    common_jvm_flags = [
        "-Dplugin.jar.location=$(execpath //third_party/dependency_analyzer/src/main:dependency_analyzer)",
        "-Dscala.library.location=$(rootpath @io_bazel_rules_scala_scala_library%s)" % suffix,
    ] + select_for_scala_version(
        any_2 = ["-Dscala.reflect.location=$(rootpath @io_bazel_rules_scala_scala_reflect%s)" % suffix],
        any_3 = ["-Dscala.library2.location=$(rootpath @io_bazel_rules_scala_scala_library_2%s)" % suffix],
    )

    scala_std_dependencies = ["@io_bazel_rules_scala_scala_library" + suffix] + select_for_scala_version(
        any_2 = ["@io_bazel_rules_scala_scala_reflect" + suffix],
        any_3 = ["@io_bazel_rules_scala_scala_library_2" + suffix],
    )

    scala_test(
        name = "ast_used_jar_finder_test",
        size = "small",
        srcs = [
            "io/bazel/rulesscala/dependencyanalyzer/AstUsedJarFinderTest.scala",
        ],
        jvm_flags = common_jvm_flags,
        deps = scala_std_dependencies + [
            "//src/java/io/bazel/rulesscala/io_utils",
            "//third_party/dependency_analyzer/src/main:dependency_analyzer",
            "//third_party/dependency_analyzer/src/main:scala_version",
            "//third_party/utils/src/test:test_util",
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
        deps = scala_std_dependencies + [
            "//src/java/io/bazel/rulesscala/io_utils",
            "//third_party/dependency_analyzer/src/main:dependency_analyzer",
            "//third_party/utils/src/test:test_util",
            "@io_bazel_rules_scala_scala_compiler" + suffix,
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
            "-Dapache.commons.jar.location=$(rootpath @org_apache_commons_commons_lang_3_5_without_file//:linkable_org_apache_commons_commons_lang_3_5_without_file)",
        ],
        unused_dependency_checker_mode = "off",
        deps = scala_std_dependencies + [
            "//third_party/dependency_analyzer/src/main:dependency_analyzer",
            "//third_party/utils/src/test:test_util",
            "@com_google_guava_guava_21_0_with_file//jar",
            "@io_bazel_rules_scala_scala_compiler" + suffix,
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
            "-Dapache.commons.jar.location=$(rootpath @org_apache_commons_commons_lang_3_5_without_file//:linkable_org_apache_commons_commons_lang_3_5_without_file)",
        ],
        unused_dependency_checker_mode = "off",
        deps = scala_std_dependencies + [
            "//third_party/dependency_analyzer/src/main:dependency_analyzer",
            "//third_party/utils/src/test:test_util",
            "@io_bazel_rules_scala_scala_compiler" + suffix,
            "@org_apache_commons_commons_lang_3_5_without_file//:linkable_org_apache_commons_commons_lang_3_5_without_file",
        ],
    )

    scala_test(
        name = "test_that_tests_run",
        size = "small",
        jvm_flags = common_jvm_flags,
        srcs = [
            "io/bazel/rulesscala/dependencyanalyzer/CompileTest.scala",
        ],
        unused_dependency_checker_mode = "off",
        deps = scala_std_dependencies + [
            "//third_party/dependency_analyzer/src/main:dependency_analyzer",
            "//third_party/utils/src/test:test_util",
        ],
    )

    scala_test(
        name = "scala_version_test",
        srcs = ["io/bazel/rulesscala/dependencyanalyzer/ScalaVersionTest.scala"],
        deps = ["//third_party/dependency_analyzer/src/main:scala_version"],
    )

def version_specific_tests():
    if SCALA_MAJOR_VERSION.startswith("2"):
        analyzer_tests_scala_2(SCALA_VERSION)

def analyzer_tests_scala_2(scala_version):
    suffix = version_suffix(scala_version)

    scala_test(
        name = "scala_version_macros_test",
        size = "small",
        srcs = [
            "io/bazel/rulesscala/dependencyanalyzer/ScalaVersionMacrosTest.scala",
        ],
        deps = [
            "//third_party/dependency_analyzer/src/main:scala_version",
            "@io_bazel_rules_scala_scala_library" + suffix,
            "@io_bazel_rules_scala_scala_reflect" + suffix,
        ],
    )
