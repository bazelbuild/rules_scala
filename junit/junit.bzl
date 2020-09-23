load(
    "//scala:scala_cross_version.bzl",
    _default_maven_server_urls = "default_maven_server_urls",
)
load("//third_party/repositories:repositories.bzl", "repositories")

def junit_repositories(
        maven_servers = _default_maven_server_urls(),
        fetch_sources = True):
    repositories(
        for_artifact_ids = [
            "io_bazel_rules_scala_junit_junit",
            "io_bazel_rules_scala_org_hamcrest_hamcrest_core",
        ],
        fetch_sources = fetch_sources,
        maven_servers = maven_servers,
    )

    native.bind(
        name = "io_bazel_rules_scala/dependency/junit/junit",
        actual = "@io_bazel_rules_scala_junit_junit//jar",
    )
    native.bind(
        name = "io_bazel_rules_scala/dependency/hamcrest/hamcrest_core",
        actual = "@io_bazel_rules_scala_org_hamcrest_hamcrest_core//jar",
    )

    native.register_toolchains("@io_bazel_rules_scala//testing:testing_toolchain")
