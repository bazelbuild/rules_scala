licenses(["notice"])  # 3-clause BSD

load("//scala:scala.bzl", "scala_junit_test", "scala_test")

scala_test(
    name = "unused_dependency_checker_test",
    size = "small",
    unused_dependency_checker_mode = "off",
    srcs = [
        "io/bazel/rulesscala/dependencyanalyzer/UnusedDependencyCheckerTest.scala",
    ],
    jvm_flags = [
        "-Dplugin.jar.location=$(location //third_party/unused_dependency_checker/src/main:unused_dependency_checker)",
        "-Dscala.library.location=$(location //external:io_bazel_rules_scala/dependency/scala/scala_library)",
        "-Dapache.commons.jar.location=$(location @org_apache_commons_commons_lang_3_5_without_file//:linkable_org_apache_commons_commons_lang_3_5_without_file)",
    ],
    deps = [
        "//external:io_bazel_rules_scala/dependency/scala/scala_compiler",
        "//external:io_bazel_rules_scala/dependency/scala/scala_library",
        "//external:io_bazel_rules_scala/dependency/scala/scala_reflect",
        "//third_party/unused_dependency_checker/src/main:unused_dependency_checker",
        "//third_party/utils/src/test:test_util",
        "@org_apache_commons_commons_lang_3_5_without_file//:linkable_org_apache_commons_commons_lang_3_5_without_file",
    ],
)
