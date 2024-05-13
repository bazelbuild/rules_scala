load(":analyzer_test_scala_2.bzl", "analyzer_tests_scala_2")
load(":analyzer_test_scala_3.bzl", "analyzer_tests_scala_3")
load("@io_bazel_rules_scala_config//:config.bzl", "SCALA_MAJOR_VERSION", "SCALA_VERSION")

def tests():
    if SCALA_MAJOR_VERSION.startswith("2"):
        analyzer_tests_scala_2(SCALA_VERSION)
    else:
        analyzer_tests_scala_3(SCALA_VERSION)
