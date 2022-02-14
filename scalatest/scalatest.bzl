load(
    "//scala:scala_cross_version.bzl",
    _default_maven_server_urls = "default_maven_server_urls",
)
load("//third_party/repositories:repositories.bzl", "repositories")

def scalatest_repositories(
        maven_servers = _default_maven_server_urls(),
        fetch_sources = True):
    repositories(
        for_artifact_ids = [
            "io_bazel_rules_scala_scalatest",
            "io_bazel_rules_scala_scalactic",
        ],
        maven_servers = maven_servers,
        fetch_sources = fetch_sources,
    )
