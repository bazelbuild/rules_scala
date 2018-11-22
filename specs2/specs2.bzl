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
    return "3.8.8"

def specs2_repositories(
        scala_version = _default_scala_version(),
        maven_servers = ["http://central.maven.org/maven2"]):
    major_version = _extract_major_version(scala_version)

    scala_jar_shas = {
        "2.11": {
            "specs2_core": "692eafc052a838c0c8552afc1a15e10978979d1703c812bd16f572d77ddd07ab",
            "specs2_common": "ba06a6218704cff61296e13300a87b07ac5ab5ad45fc82dce37e550101b8cdb5",
            "specs2_matcher": "9c8cc2148a6692aa4e2fcd1282c28971215f501f10d532d1a3a3c33fd803fedc",
            "scalaz_effect": "4d45f0d1bb6958f5c6781a5e94d9528934b6a1404346d224dda25da064b0c964",
            "scalaz_core": "810504bc8d669913af830dd5d9c87f83e0570898f09be6474f0d5603bba8ba79",
        },
        "2.12": {
            "specs2_core": "1fc47c1199675ed60b58923c84006cc4f776818b11e0a18a47db29c03a60ee97",
            "specs2_common": "c0a892fd1a5a1aaf5bb29792e39da5459f1564a721d9a6a0954fb52c395b2deb",
            "specs2_matcher": "c17b8f1e4c3da6c1489c59f67e03374b358fdfbe90d9def2a7e4e1b1b10f5046",
            "scalaz_effect": "eca21ba69a1532c74ea77356b59d6175a5fd54dac7f57f1d1979738c98521919",
            "scalaz_core": "b53cd091daec1c8df8c4244e5b8b460b7416c2cc86aecd25dec4c93d2baf2b04",
        },
    }

    scala_version_jar_shas = scala_jar_shas[major_version]

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
        name = "io_bazel_rules_scala_org_specs2_specs2_matcher",
        artifact = _scala_mvn_artifact(
            "org.specs2:specs2-matcher:" + specs2_version(),
            major_version,
        ),
        jar_sha256 = scala_version_jar_shas["specs2_matcher"],
        licenses = ["notice"],
        server_urls = maven_servers,
    )

    _scala_maven_import_external(
        name = "io_bazel_rules_scala_org_scalaz_scalaz_effect",
        artifact = _scala_mvn_artifact(
            "org.scalaz:scalaz-effect:7.2.7",
            major_version,
        ),
        jar_sha256 = scala_version_jar_shas["scalaz_effect"],
        licenses = ["notice"],
        server_urls = maven_servers,
    )

    _scala_maven_import_external(
        name = "io_bazel_rules_scala_org_scalaz_scalaz_core",
        artifact = _scala_mvn_artifact(
            "org.scalaz:scalaz-core:7.2.7",
            major_version,
        ),
        jar_sha256 = scala_version_jar_shas["scalaz_core"],
        licenses = ["notice"],
        server_urls = maven_servers,
    )

    native.bind(
        name = "io_bazel_rules_scala/dependency/specs2/specs2",
        actual = "@io_bazel_rules_scala//specs2:specs2",
    )

def specs2_dependencies():
    return ["//external:io_bazel_rules_scala/dependency/specs2/specs2"]
