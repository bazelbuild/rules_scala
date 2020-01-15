load(
    "@io_bazel_rules_scala//scala:scala_maven_import_external.bzl",
    _scala_maven_import_external = "scala_maven_import_external",
)

def junit_repositories(maven_servers = ["https://repo.maven.apache.org/maven2"]):
    _scala_maven_import_external(
        name = "io_bazel_rules_scala_junit_junit",
        artifact = "junit:junit:4.12",
        artifact_sha256 = "59721f0805e223d84b90677887d9ff567dc534d7c502ca903c0c2b17f05c116a",
        licenses = ["notice"],
        server_urls = maven_servers,
    )
    native.bind(
        name = "io_bazel_rules_scala/dependency/junit/junit",
        actual = "@io_bazel_rules_scala_junit_junit//jar",
    )

    _scala_maven_import_external(
        name = "io_bazel_rules_scala_org_hamcrest_hamcrest_core",
        artifact = "org.hamcrest:hamcrest-core:1.3",
        artifact_sha256 = "66fdef91e9739348df7a096aa384a5685f4e875584cce89386a7a47251c4d8e9",
        licenses = ["notice"],
        server_urls = maven_servers,
    )
    native.bind(
        name = "io_bazel_rules_scala/dependency/hamcrest/hamcrest_core",
        actual = "@io_bazel_rules_scala_org_hamcrest_hamcrest_core//jar",
    )
