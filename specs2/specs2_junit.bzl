load(
    "//specs2:specs2.bzl",
    "specs2_dependencies",
    "specs2_repositories",
)
load("//testing:junit.bzl", "junit_repositories")
load(
    "//scala:scala_cross_version.bzl",
    _default_maven_server_urls = "default_maven_server_urls",
)
load("//third_party/repositories:repositories.bzl", "repositories")

def specs2_junit_artifact_ids():
    return [
        "io_bazel_rules_scala_org_specs2_specs2_junit",
    ]

def specs2_junit_repositories(
        maven_servers = _default_maven_server_urls(),
        overriden_artifacts = {}):
    specs2_repositories(maven_servers)
    junit_repositories()

    repositories(
        for_artifact_ids = specs2_junit_artifact_ids(),
        maven_servers = maven_servers,
        fetch_sources = True,
        overriden_artifacts = overriden_artifacts,
    )

def specs2_junit_dependencies():
    return specs2_dependencies() + [
        Label("//testing/toolchain:specs2_junit_classpath"),
    ]
