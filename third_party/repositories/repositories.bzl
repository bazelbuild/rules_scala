load("//third_party/repositories:scala_2_11.bzl", _artifacts_2_11 = "artifacts")
load("//third_party/repositories:scala_2_12.bzl", _artifacts_2_12 = "artifacts")
load(
    "@io_bazel_rules_scala//scala:scala_cross_version.bzl",
    "default_maven_server_urls",
    "extract_major_version",
)
load(
    "@io_bazel_rules_scala//scala:scala_maven_import_external.bzl",
    _scala_maven_import_external = "scala_maven_import_external",
)
load("@io_bazel_rules_scala_config//:config.bzl", "SCALA_MAJOR_VERSION")

artifacts_by_major_scala_version = {
    "2.11": _artifacts_2_11,
    "2.12": _artifacts_2_12,
}

def repositories(
        for_artifact_ids = [],
        maven_servers = default_maven_server_urls(),
        overriden_artifacts = {},
        fetch_sources = True):
    major_scala_version = SCALA_MAJOR_VERSION
    default_artifacts = artifacts_by_major_scala_version[major_scala_version]
    artifacts = dict(default_artifacts.items() + overriden_artifacts.items())
    for id in for_artifact_ids:
        _scala_maven_import_external(
            name = id,
            artifact = artifacts[id]["artifact"],
            artifact_sha256 = artifacts[id]["sha256"],
            licenses = ["notice"],
            server_urls = maven_servers,
            deps = artifacts[id].get("deps", []),
            runtime_deps = artifacts[id].get("runtime_deps", []),
            testonly_ = artifacts[id].get("testonly", False),
            fetch_sources = fetch_sources,
        )
