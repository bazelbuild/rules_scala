load("@io_bazel_rules_scala//scala:scala.bzl", "scala_test")

def analyzer_tests_scala_3():
    common_jvm_flags = [
    ]

    scala_test(
        name = "test_that_tests_run",
        srcs = [
            "io/bazel/rulesscala/dependencyanalyzer3/Test.scala",
        ],
    )
