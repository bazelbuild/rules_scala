load("@io_bazel_rules_scala//scala:scala.bzl", "scala_test")

def analyzer_tests_scala_3():
    common_jvm_flags = [
        "-Dplugin.jar.location=$(execpath //third_party/dependency_analyzer/src/main:dependency_analyzer)",
        "-Dscala.library.location=$(rootpath @io_bazel_rules_scala_scala_library)",
        "-Dscala.library2.location=$(rootpath @io_bazel_rules_scala_scala_library_2)",
    ]

    scala_test(
        name = "test_that_tests_run",
        size = "small",
        jvm_flags = common_jvm_flags,
        srcs = [
            "io/bazel/rulesscala/dependencyanalyzer3/CompileTest.scala",
        ],
        deps = [
            "//scala/private/toolchain_deps:scala_compile_classpath",
            "//third_party/dependency_analyzer/src/main:dependency_analyzer",
            "//third_party/utils/src/test:test_util",
            "@io_bazel_rules_scala_scala_library",
            "@io_bazel_rules_scala_scala_library_2",
        ],
    )
