load(":analyzer_test_scala_2.bzl", "analyzer_tests_scala_2")
load(":analyzer_test_scala_3.bzl", "analyzer_tests_scala_3")
load("@io_bazel_rules_scala_config//:config.bzl", "SCALA_VERSION")
load("@io_bazel_rules_scala//scala:scala_cross_version.bzl", "version_suffix")

def tests():
    suffix = version_suffix(SCALA_VERSION)
    if SCALA_VERSION.startswith("2"):
        analyzer_tests_scala_2(suffix)
    else:
        analyzer_tests_scala_3(suffix)
