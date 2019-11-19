load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load(
    "@io_bazel_rules_scala//scala:scala_cross_version.bzl",
    _default_scala_version = "default_scala_version",
    _default_scala_version_jar_shas = "default_scala_version_jar_shas",
    _extract_major_version = "extract_major_version",
    _new_scala_default_repository = "new_scala_default_repository",
)
load(
    "@io_bazel_rules_scala//scala:scala_maven_import_external.bzl",
    _scala_maven_import_external = "scala_maven_import_external",
)

def _default_scala_extra_jars():
    return {
        "2.11": {
            "scalatest": {
                "version": "3.0.5",
                "sha256": "2aafeb41257912cbba95f9d747df9ecdc7ff43f039d35014b4c2a8eb7ed9ba2f",
            },
            "scalactic": {
                "version": "3.0.5",
                "sha256": "84723064f5716f38990fe6e65468aa39700c725484efceef015771d267341cf2",
            },
            "scala_xml": {
                "version": "1.0.5",
                "sha256": "767e11f33eddcd506980f0ff213f9d553a6a21802e3be1330345f62f7ee3d50f",
            },
            "scala_parser_combinators": {
                "version": "1.0.4",
                "sha256": "0dfaafce29a9a245b0a9180ec2c1073d2bd8f0330f03a9f1f6a74d1bc83f62d6",
            },
        },
        "2.12": {
            "scalatest": {
                "version": "3.0.5",
                "sha256": "b416b5bcef6720da469a8d8a5726e457fc2d1cd5d316e1bc283aa75a2ae005e5",
            },
            "scalactic": {
                "version": "3.0.5",
                "sha256": "57e25b4fd969b1758fe042595112c874dfea99dca5cc48eebe07ac38772a0c41",
            },
            "scala_xml": {
                "version": "1.0.5",
                "sha256": "035015366f54f403d076d95f4529ce9eeaf544064dbc17c2d10e4f5908ef4256",
            },
            "scala_parser_combinators": {
                "version": "1.0.4",
                "sha256": "282c78d064d3e8f09b3663190d9494b85e0bb7d96b0da05994fe994384d96111",
            },
        },
    }

def scala_repositories(
        scala_version_shas = (
            _default_scala_version(),
            _default_scala_version_jar_shas(),
        ),
        maven_servers = ["http://central.maven.org/maven2"],
        scala_extra_jars = _default_scala_extra_jars()):
    (scala_version, scala_version_jar_shas) = scala_version_shas
    major_version = _extract_major_version(scala_version)

    _new_scala_default_repository(
        maven_servers = maven_servers,
        scala_version = scala_version,
        scala_version_jar_shas = scala_version_jar_shas,
    )

    scala_version_extra_jars = scala_extra_jars[major_version]

    _scala_maven_import_external(
        name = "io_bazel_rules_scala_scalatest",
        artifact = "org.scalatest:scalatest_{major_version}:{extra_jar_version}".format(
            major_version = major_version,
            extra_jar_version = scala_version_extra_jars["scalatest"]["version"],
        ),
        artifact_sha256 = scala_version_extra_jars["scalatest"]["sha256"],
        licenses = ["notice"],
        server_urls = maven_servers,
    )
    _scala_maven_import_external(
        name = "io_bazel_rules_scala_scalactic",
        artifact = "org.scalactic:scalactic_{major_version}:{extra_jar_version}".format(
            major_version = major_version,
            extra_jar_version = scala_version_extra_jars["scalactic"]["version"],
        ),
        artifact_sha256 = scala_version_extra_jars["scalactic"]["sha256"],
        licenses = ["notice"],
        server_urls = maven_servers,
    )

    _scala_maven_import_external(
        name = "io_bazel_rules_scala_scala_xml",
        artifact = "org.scala-lang.modules:scala-xml_{major_version}:{extra_jar_version}".format(
            major_version = major_version,
            extra_jar_version = scala_version_extra_jars["scala_xml"]["version"],
        ),
        artifact_sha256 = scala_version_extra_jars["scala_xml"]["sha256"],
        licenses = ["notice"],
        server_urls = maven_servers,
    )

    _scala_maven_import_external(
        name = "io_bazel_rules_scala_scala_parser_combinators",
        artifact =
            "org.scala-lang.modules:scala-parser-combinators_{major_version}:{extra_jar_version}".format(
                major_version = major_version,
                extra_jar_version = scala_version_extra_jars["scala_parser_combinators"]["version"],
            ),
        artifact_sha256 = scala_version_extra_jars["scala_parser_combinators"]["sha256"],
        licenses = ["notice"],
        server_urls = maven_servers,
    )

    # used by ScalacProcessor
    _scala_maven_import_external(
        name = "scalac_rules_commons_io",
        artifact = "commons-io:commons-io:2.6",
        artifact_sha256 = "f877d304660ac2a142f3865badfc971dec7ed73c747c7f8d5d2f5139ca736513",
        licenses = ["notice"],
        server_urls = maven_servers,
    )

    _scala_maven_import_external(
        name = "io_bazel_rules_scala_guava",
        artifact = "com.google.guava:guava:21.0",
        artifact_sha256 = "972139718abc8a4893fa78cba8cf7b2c903f35c97aaf44fa3031b0669948b480",
        licenses = ["notice"],
        server_urls = maven_servers,
    )

    if not native.existing_rule("com_google_protobuf"):
        http_archive(
            name = "com_google_protobuf",
            sha256 = "d82eb0141ad18e98de47ed7ed415daabead6d5d1bef1b8cccb6aa4d108a9008f",
            strip_prefix = "protobuf-b4f193788c9f0f05d7e0879ea96cd738630e5d51",
            # Commit from 2019-05-15, update to protobuf 3.8 when available.
            urls = [
                "https://mirror.bazel.build/github.com/protocolbuffers/protobuf/archive/b4f193788c9f0f05d7e0879ea96cd738630e5d51.tar.gz",
                "https://github.com/protocolbuffers/protobuf/archive/b4f193788c9f0f05d7e0879ea96cd738630e5d51.tar.gz",
            ],
        )

    if not native.existing_rule("zlib"):  # needed by com_google_protobuf
        http_archive(
            name = "zlib",
            build_file = "@com_google_protobuf//:third_party/zlib.BUILD",
            sha256 = "c3e5e9fdd5004dcb542feda5ee4f0ff0744628baf8ed2dd5d66f8ca1197cb1a1",
            strip_prefix = "zlib-1.2.11",
            urls = [
                "https://mirror.bazel.build/zlib.net/zlib-1.2.11.tar.gz",
                "https://zlib.net/zlib-1.2.11.tar.gz",
            ],
        )

    native.bind(
        name = "io_bazel_rules_scala/dependency/com_google_protobuf/protobuf_java",
        actual = "@com_google_protobuf//:protobuf_java",
    )

    native.bind(
        name = "io_bazel_rules_scala/dependency/commons_io/commons_io",
        actual = "@scalac_rules_commons_io//jar",
    )

    native.bind(
        name = "io_bazel_rules_scala/dependency/scalatest/scalatest",
        actual = "@io_bazel_rules_scala//scala/scalatest:scalatest",
    )

    native.bind(
        name = "io_bazel_rules_scala/dependency/scala/scala_compiler",
        actual = "@io_bazel_rules_scala_scala_compiler",
    )

    native.bind(
        name = "io_bazel_rules_scala/dependency/scala/scala_library",
        actual = "@io_bazel_rules_scala_scala_library",
    )

    native.bind(
        name = "io_bazel_rules_scala/dependency/scala/scala_reflect",
        actual = "@io_bazel_rules_scala_scala_reflect",
    )

    native.bind(
        name = "io_bazel_rules_scala/dependency/scala/scala_xml",
        actual = "@io_bazel_rules_scala_scala_xml",
    )

    native.bind(
        name = "io_bazel_rules_scala/dependency/scala/parser_combinators",
        actual = "@io_bazel_rules_scala_scala_parser_combinators",
    )

    native.bind(
        name = "io_bazel_rules_scala/dependency/scala/guava",
        actual = "@io_bazel_rules_scala_guava",
    )
