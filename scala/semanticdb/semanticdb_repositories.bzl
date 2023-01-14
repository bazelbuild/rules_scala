load(
    "//scala:scala_cross_version.bzl",
    _default_maven_server_urls = "default_maven_server_urls",
)
load("//third_party/repositories:repositories.bzl", "repositories")


def semanticdb_repositories(
        maven_servers = _default_maven_server_urls(),
        overriden_artifacts = {}):
    repositories(
        for_artifact_ids = ["org_scalameta_semanticdb_scalac"],
        maven_servers = maven_servers,
        fetch_sources = False,
        overriden_artifacts = overriden_artifacts,
    )
