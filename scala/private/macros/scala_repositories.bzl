load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load(
    "@io_bazel_rules_scala//scala:scala_cross_version.bzl",
    _default_maven_server_urls = "default_maven_server_urls",
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
        maven_servers = _default_maven_server_urls(),
        scala_extra_jars = _default_scala_extra_jars(),
        fetch_sources = False):
    (scala_version, scala_version_jar_shas) = scala_version_shas
    major_version = _extract_major_version(scala_version)

    _new_scala_default_repository(
        maven_servers = maven_servers,
        scala_version = scala_version,
        scala_version_jar_shas = scala_version_jar_shas,
        fetch_sources = fetch_sources,
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
        fetch_sources = fetch_sources,
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
        fetch_sources = fetch_sources,
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
        fetch_sources = fetch_sources,
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
        fetch_sources = fetch_sources,
    )

    if not native.existing_rule("com_google_protobuf"):
        http_archive(
            name = "com_google_protobuf",
            sha256 = "cf754718b0aa945b00550ed7962ddc167167bd922b842199eeb6505e6f344852",
            strip_prefix = "protobuf-3.11.3",
            urls = [
                "https://mirror.bazel.build/github.com/protocolbuffers/protobuf/archive/v3.11.3.tar.gz",
                "https://github.com/protocolbuffers/protobuf/archive/v3.11.3.tar.gz",
            ],
        )

    if not native.existing_rule("rules_cc"):
        http_archive(
            name = "rules_cc",
            sha256 = "29daf0159f0cf552fcff60b49d8bcd4f08f08506d2da6e41b07058ec50cfeaec",
            strip_prefix = "rules_cc-b7fe9697c0c76ab2fd431a891dbb9a6a32ed7c3e",
            urls = ["https://github.com/bazelbuild/rules_cc/archive/b7fe9697c0c76ab2fd431a891dbb9a6a32ed7c3e.tar.gz"],
        )

    if not native.existing_rule("rules_java"):
        http_archive(
            name = "rules_java",
            sha256 = "220b87d8cfabd22d1c6d8e3cdb4249abd4c93dcc152e0667db061fb1b957ee68",
            urls = ["https://github.com/bazelbuild/rules_java/releases/download/0.1.1/rules_java-0.1.1.tar.gz"],
        )

    if not native.existing_rule("rules_proto"):
        http_archive(
            name = "rules_proto",
            sha256 = "4d421d51f9ecfe9bf96ab23b55c6f2b809cbaf0eea24952683e397decfbd0dd0",
            strip_prefix = "rules_proto-f6b8d89b90a7956f6782a4a3609b2f0eee3ce965",
            urls = [
                "https://mirror.bazel.build/github.com/bazelbuild/rules_proto/archive/f6b8d89b90a7956f6782a4a3609b2f0eee3ce965.tar.gz",
                "https://github.com/bazelbuild/rules_proto/archive/f6b8d89b90a7956f6782a4a3609b2f0eee3ce965.tar.gz",
            ],
        )

    if not native.existing_rule("rules_python"):
        http_archive(
            name = "rules_python",
            sha256 = "e5470e92a18aa51830db99a4d9c492cc613761d5bdb7131c04bd92b9834380f6",
            strip_prefix = "rules_python-4b84ad270387a7c439ebdccfd530e2339601ef27",
            urls = ["https://github.com/bazelbuild/rules_python/archive/4b84ad270387a7c439ebdccfd530e2339601ef27.tar.gz"],
        )

    if not native.existing_rule("zlib"):  # needed by com_google_protobuf
        http_archive(
            name = "zlib",
            build_file = "@com_google_protobuf//third_party:zlib.BUILD",
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
        name = "io_bazel_rules_scala/dependency/scala/scalatest/scalatest",
        actual = "@io_bazel_rules_scala_scalatest",
    )

    native.bind(
        name = "io_bazel_rules_scala/dependency/scala/scalactic/scalactic",
        actual = "@io_bazel_rules_scala_scalactic",
    )
