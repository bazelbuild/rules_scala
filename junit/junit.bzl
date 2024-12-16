load(
    "//scala:scala_cross_version.bzl",
    _default_maven_server_urls = "default_maven_server_urls",
)
load("//third_party/repositories:repositories.bzl", "repositories")

def junit_artifact_ids():
    return [
        "io_bazel_rules_scala_junit_junit",
        "io_bazel_rules_scala_org_hamcrest_hamcrest_core",
    ]

def junit_repositories(
        maven_servers = _default_maven_server_urls(),
        fetch_sources = True):
    repositories(
        for_artifact_ids = junit_artifact_ids(),
        fetch_sources = fetch_sources,
        maven_servers = maven_servers,
    )
