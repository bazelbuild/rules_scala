load(
    "//specs2:specs2.bzl",
    "specs2_dependencies",
    "specs2_repositories",
    "specs2_version",
)
load("//testing:junit.bzl", "junit_repositories")
load(
    "//scala:scala_cross_version.bzl",
    _default_maven_server_urls = "default_maven_server_urls",
    _default_scala_version = "default_scala_version",
)
load("//third_party/repositories:repositories.bzl", "repositories")

def specs2_junit_repositories(
        scala_version = _default_scala_version(),
        maven_servers = _default_maven_server_urls(),
        overriden_artifacts = {}):
    specs2_repositories(scala_version, maven_servers)
    junit_repositories()

    repositories(
        for_artifact_ids = [
            "io_bazel_rules_scala_org_specs2_specs2_junit",
        ],
        scala_version = scala_version,
        maven_servers = maven_servers,
        fetch_sources = True,
        overriden_artifacts = overriden_artifacts,
    )

    native.bind(
        name = "io_bazel_rules_scala/dependency/specs2/specs2_junit",
        actual = "@io_bazel_rules_scala_org_specs2_specs2_junit",
    )

def specs2_junit_dependencies():
    return specs2_dependencies() + [
        "//external:io_bazel_rules_scala/dependency/specs2/specs2_junit",
    ]
