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

def scalafmt_default_config(path = ".scalafmt.conf"):
    build = []
    build.append("filegroup(")
    build.append("    name = \"config\",")
    build.append("    srcs = [\"{}\"],".format(path))
    build.append("    visibility = [\"//visibility:public\"],")
    build.append(")")
    native.new_local_repository(name = "scalafmt_default", build_file_content = "\n".join(build), path = "")

def scalafmt_repositories(
        scala_version = _default_scala_version(),
        maven_servers = ["http://central.maven.org/maven2"]):
    major_version = _extract_major_version(scala_version)

    scala_jar_shas = {
        "2.11": {
            "scalafmt_parsers": "acde4faa648c61f1d76f7a1152116738c0b0b80ae2fab8ceae83c061c29aadf1",
            "metaconfig_core": "8abb4e48507486d0b323b440bb021bddd56366e502002025fdaf10025d2650c2",
            "scalafmt_core": "84bac5ed8c85e61851ef427f045b7bfd149d857cb543b41c85b8353fb8c47aff",
        },
        "2.12": {
            "scalafmt_parsers": "9dc726dab95870b193dee3ed4d11985fa38ca09640768a7c86d8f80c715c5567",
            "metaconfig_core": "495817d90ecb4c432ee0afa7e79b4d005e6a6f90a270e113e15fe7d2d5559dfd",
            "scalafmt_core": "02562f176a7d070230ef2da6192f2d15afd62ea173eaf8ca02a7afb89262d233",
        },
    }

    scala_version_jar_shas = scala_jar_shas[major_version]

    _scala_maven_import_external(
        name = "scalafmt_parsers",
        artifact = _scala_mvn_artifact(
            "org.scalameta:parsers:4.2.0",
            major_version,
        ),
        artifact_sha256 = scala_version_jar_shas["scalafmt_parsers"],
        licenses = ["notice"],
        server_urls = maven_servers,
    )

    native.bind(
        name = "io_bazel_rules_scala/scalafmt/scalafmt_parsers",
        actual = "@scalafmt_parsers",
    )

    _scala_maven_import_external(
        name = "geirsson_metaconfig_core",
        artifact = _scala_mvn_artifact(
            "com.geirsson:metaconfig-core:0.8.3",
            major_version,
        ),
        artifact_sha256 = scala_version_jar_shas["metaconfig_core"],
        licenses = ["notice"],
        server_urls = maven_servers,
    )

    native.bind(
        name = "io_bazel_rules_scala/scalafmt/geirsson_metaconfig_core",
        actual = "@geirsson_metaconfig_core",
    )

    _scala_maven_import_external(
        name = "scalafmt_core",
        artifact = _scala_mvn_artifact(
            "org.scalameta:scalafmt-core:2.0.0",
            major_version,
        ),
        artifact_sha256 = scala_version_jar_shas["scalafmt_core"],
        licenses = ["notice"],
        server_urls = maven_servers,
    )

    native.bind(
        name = "io_bazel_rules_scala/scalafmt/scalafmt_core",
        actual = "@scalafmt_core",
    )

    _scala_maven_import_external(
        name = "argparse4j",
        artifact = "net.sourceforge.argparse4j:argparse4j:0.8.1",
        artifact_sha256 = "98cb5468cac609f3bc07856f2e34088f50dc114181237c48d20ca69c3265d044",
        licenses = ["notice"],
        server_urls = maven_servers,
    )

    native.bind(
        name = "io_bazel_rules_scala/scalafmt/argparse4j",
        actual = "@argparse4j",
    )
