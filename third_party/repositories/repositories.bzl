load(
    "//third_party/repositories:scala_2_11.bzl",
    _artifacts_2_11 = "artifacts",
    _scala_version_2_11 = "scala_version",
)
load(
    "//third_party/repositories:scala_2_12.bzl",
    _artifacts_2_12 = "artifacts",
    _scala_version_2_12 = "scala_version",
)
load(
    "//third_party/repositories:scala_2_13.bzl",
    _artifacts_2_13 = "artifacts",
    _scala_version_2_13 = "scala_version",
)
load(
    "//third_party/repositories:scala_3_1.bzl",
    _artifacts_3_1 = "artifacts",
    _scala_version_3_1 = "scala_version",
)
load(
    "//third_party/repositories:scala_3_2.bzl",
    _artifacts_3_2 = "artifacts",
    _scala_version_3_2 = "scala_version",
)
load(
    "//third_party/repositories:scala_3_3.bzl",
    _artifacts_3_3 = "artifacts",
    _scala_version_3_3 = "scala_version",
)
load(
    "@io_bazel_rules_scala//scala:scala_cross_version.bzl",
    "default_maven_server_urls",
)
load(
    "@io_bazel_rules_scala//scala:scala_maven_import_external.bzl",
    _scala_maven_import_external = "scala_maven_import_external",
)
load("@io_bazel_rules_scala_config//:config.bzl", "SCALA_MAJOR_VERSION", "SCALA_VERSION")
load("//scala:scala_cross_version.bzl", "extract_major_version", "version_suffix")

artifacts_by_major_scala_version = {
    "2.11": _artifacts_2_11,
    "2.12": _artifacts_2_12,
    "2.13": _artifacts_2_13,
    "3.1": _artifacts_3_1,
    "3.2": _artifacts_3_2,
    "3.3": _artifacts_3_3,
}

scala_version_by_major_scala_version = {
    "2.11": _scala_version_2_11,
    "2.12": _scala_version_2_12,
    "2.13": _scala_version_2_13,
    "3.1": _scala_version_3_1,
    "3.2": _scala_version_3_2,
    "3.3": _scala_version_3_3,
}

def repositories(
        for_artifact_ids = [],
        maven_servers = default_maven_server_urls(),
        overriden_artifacts = {},
        fetch_sources = True,
        validate_scala_version = False):
    major_scala_version = SCALA_MAJOR_VERSION

    if validate_scala_version:
        repository_scala_version = scala_version_by_major_scala_version[SCALA_MAJOR_VERSION]
        default_version_matches = SCALA_VERSION == repository_scala_version

        if not default_version_matches and len(overriden_artifacts) == 0:
            version_message = "Scala config (%s) version does not match repository version (%s)"
            fail(version_message % (SCALA_VERSION, repository_scala_version))

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

def toolchain_repositories(
        scala_version,
        for_artifact_ids = [],
        maven_servers = default_maven_server_urls(),
        overriden_artifacts = {},
        fetch_sources = True,
        validate_scala_version = False):
    major_scala_version = extract_major_version(scala_version)

    if validate_scala_version:
        repository_scala_version = scala_version_by_major_scala_version[major_scala_version]
        default_version_matches = scala_version == repository_scala_version

        if not default_version_matches and len(overriden_artifacts) == 0:
            version_message = "Scala config (%s) version does not match repository version (%s)"
            fail(version_message % (scala_version, repository_scala_version))

    default_artifacts = artifacts_by_major_scala_version[major_scala_version]
    artifacts = dict(default_artifacts.items() + overriden_artifacts.items())
    suffix = version_suffix(scala_version)
    for id in for_artifact_ids:
        _scala_maven_import_external(
            name = id + suffix,
            artifact = artifacts[id]["artifact"],
            artifact_sha256 = artifacts[id]["sha256"],
            licenses = ["notice"],
            server_urls = maven_servers,
            deps = [dep + suffix for dep in artifacts[id].get("deps", [])],
            runtime_deps = artifacts[id].get("runtime_deps", []),
            testonly_ = artifacts[id].get("testonly", False),
            fetch_sources = fetch_sources,
        )
