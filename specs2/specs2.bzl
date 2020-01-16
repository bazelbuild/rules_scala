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
    return "4.4.1"

def specs2_repositories(
        scala_version = _default_scala_version(),
        maven_servers = ["https://repo1.maven.org/maven2"]):
    major_version = _extract_major_version(scala_version)

    scala_jar_shas = {
        "2.11": {
            "specs2_common": "52d7c0da58725606e98c6e8c81d2efe632053520a25da9140116d04a4abf9d2c",
            "specs2_core": "8e95cb7e347e7a87e7a80466cbd88419ece1aaacb35c32e8bd7d299a623b31b9",
            "specs2_fp": "e43006fdd0726ffcd1e04c6c4d795176f5f765cc787cc09baebe1fcb009e4462",
            "specs2_matcher": "448e5ab89d4d650d23030fdbee66a010a07dcac5e4c3e73ef5fe39ca1aace1cd",
        },
        "2.12": {
            "specs2_common": "7b7d2497bfe10ad552f5ab3780537c7db9961d0ae841098d5ebd91c78d09438a",
            "specs2_core": "f92c3c83844aac13250acec4eb247a2a26a2b3f04e79ef1bf42c56de4e0bb2e7",
            "specs2_fp": "834a145b28dbf57ba6d96f02a3862522e693b5aeec44d4cb2f305ef5617dc73f",
            "specs2_matcher": "78c699001c307dcc5dcbec8a80cd9f14e9bdaa047579c3d1010ee4bea66805fe",
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
