load(
    "//specs2:specs2.bzl",
    "specs2_dependencies",
    "specs2_repositories",
    "specs2_version",
)
load("//junit:junit.bzl", "junit_repositories")
load(
    "//scala:scala_cross_version.bzl",
    _default_maven_server_urls = "default_maven_server_urls",
    _default_scala_version = "default_scala_version",
    _extract_major_version = "extract_major_version",
    _scala_mvn_artifact = "scala_mvn_artifact",
)
load(
    "@io_bazel_rules_scala//scala:scala_maven_import_external.bzl",
    _scala_maven_import_external = "scala_maven_import_external",
)

def specs2_junit_repositories(
        scala_version = _default_scala_version(),
        maven_servers = _default_maven_server_urls()):
    major_version = _extract_major_version(scala_version)

    specs2_repositories(scala_version, maven_servers)
    junit_repositories()

    scala_jar_shas = {
        "2.11": {
            "specs2_junit": "a8549d52e87896624200fe35ef7b841c1c698a8fb5d97d29bf082762aea9bb72",
        },
        "2.12": {
            "specs2_junit": "c867824801da5cccf75354da6d12d406009c435865ecd08a881b799790e9ffec",
        },
    }

    # Aditional dependencies for specs2 junit runner
    _scala_maven_import_external(
        name = "io_bazel_rules_scala_org_specs2_specs2_junit",
        artifact = _scala_mvn_artifact(
            "org.specs2:specs2-junit:" + specs2_version(),
            major_version,
        ),
        artifact_sha256 = scala_jar_shas[major_version]["specs2_junit"],
        deps = ["@io_bazel_rules_scala_org_specs2_specs2_core"],
        licenses = ["notice"],
        server_urls = maven_servers,
    )

    native.bind(
        name = "io_bazel_rules_scala/dependency/specs2/specs2_junit",
        actual = "@io_bazel_rules_scala_org_specs2_specs2_junit",
    )

def specs2_junit_dependencies():
    return specs2_dependencies() + [
        "//external:io_bazel_rules_scala/dependency/specs2/specs2_junit",
    ]
