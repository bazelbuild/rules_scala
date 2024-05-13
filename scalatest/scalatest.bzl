load(
    "//scala:scala_cross_version.bzl",
    _default_maven_server_urls = "default_maven_server_urls",
)
load("//third_party/repositories:repositories.bzl", "repositories")
load("@io_bazel_rules_scala_config//:config.bzl", "SCALA_VERSIONS")

def scalatest_repositories(
        maven_servers = _default_maven_server_urls(),
        fetch_sources = True):
    for scala_version in SCALA_VERSIONS:
        repositories(
            scala_version = scala_version,
            for_artifact_ids = [
                "io_bazel_rules_scala_scalatest",
                "io_bazel_rules_scala_scalatest_compatible",
                "io_bazel_rules_scala_scalatest_core",
                "io_bazel_rules_scala_scalatest_featurespec",
                "io_bazel_rules_scala_scalatest_flatspec",
                "io_bazel_rules_scala_scalatest_freespec",
                "io_bazel_rules_scala_scalatest_funsuite",
                "io_bazel_rules_scala_scalatest_funspec",
                "io_bazel_rules_scala_scalatest_matchers_core",
                "io_bazel_rules_scala_scalatest_shouldmatchers",
                "io_bazel_rules_scala_scalatest_mustmatchers",
                "io_bazel_rules_scala_scalactic",
            ],
            maven_servers = maven_servers,
            fetch_sources = fetch_sources,
        )
