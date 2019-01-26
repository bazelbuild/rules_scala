load(
    "//scala:scala_cross_version.bzl",
    _default_scala_version = "default_scala_version",
    _extract_major_version = "extract_major_version",
    _scala_mvn_artifact = "scala_mvn_artifact",
)
load(
    "@io_bazel_rules_scala//scala:scala_maven_import_external.bzl",
    _scala_maven_import_external = "scala_maven_import_external",
)

def specs2_version():
    return "4.3.5"

def specs2_repositories(
        scala_version = _default_scala_version(),
        maven_servers = ["http://central.maven.org/maven2"]):
    major_version = _extract_major_version(scala_version)

    scala_jar_shas = {
        "2.11": {
            "specs2_common": "363562d874da321f8191e83ff2c3dd91b448a557c481c8e5671c5e43d232d90c",
            "specs2_core": "7a878b5af6a3da9d751d8da1b054e287296c97bac9e772ef6c9edeb64a258dc4",
            "specs2_fp": "263e4fb253addc524ae0e1a3f2e99ab446fd1deb69dffecc84645150aded6a41",
            "specs2_matcher": "4f68a4a3d6f1af04be5b6a6ec4e0362fcc78636c455dc58f8c21ad86f2ff8034",
        },
        "2.12": {
            "specs2_common": "fd4a226f087041c32cad5b417d543ffb6788db6214aa2b7ec2af10d9f39ba0af",
            "specs2_core": "36f5ba21e5acdd7dd8acf7fe9b4bf39b493816037630c55ae074736a0a47c231",
            "specs2_fp": "2159c14f44425cc39f6742b124d04f1e91274570baf2f2641097c2c3080dc130",
            "specs2_matcher": "c4bccc931e8dbac360e47c5e3f57a67a090a151d43d0dba8bdbe56a6132ac83a",
        },
    }

    scala_version_jar_shas = scala_jar_shas[major_version]

    _scala_maven_import_external(
        name = "io_bazel_rules_scala_org_specs2_specs2_common",
        artifact = _scala_mvn_artifact(
            "org.specs2:specs2-common:" + specs2_version(),
            major_version,
        ),
        jar_sha256 = scala_version_jar_shas["specs2_common"],
        licenses = ["notice"],
        server_urls = maven_servers,
    )

    _scala_maven_import_external(
        name = "io_bazel_rules_scala_org_specs2_specs2_core",
        artifact = _scala_mvn_artifact(
            "org.specs2:specs2-core:" + specs2_version(),
            major_version,
        ),
        jar_sha256 = scala_version_jar_shas["specs2_core"],
        licenses = ["notice"],
        server_urls = maven_servers,
    )

    _scala_maven_import_external(
        name = "io_bazel_rules_scala_org_specs2_specs2_fp",
        artifact = _scala_mvn_artifact(
            "org.specs2:specs2-fp:" + specs2_version(),
            major_version,
        ),
        jar_sha256 = scala_version_jar_shas["specs2_fp"],
        licenses = ["notice"],
        server_urls = maven_servers,
    )

    _scala_maven_import_external(
        name = "io_bazel_rules_scala_org_specs2_specs2_matcher",
        artifact = _scala_mvn_artifact(
            "org.specs2:specs2-matcher:" + specs2_version(),
            major_version,
        ),
        jar_sha256 = scala_version_jar_shas["specs2_matcher"],
        licenses = ["notice"],
        server_urls = maven_servers,
    )

    native.bind(
        name = "io_bazel_rules_scala/dependency/specs2/specs2",
        actual = "@io_bazel_rules_scala//specs2:specs2",
    )

def specs2_dependencies():
    return ["//external:io_bazel_rules_scala/dependency/specs2/specs2"]
