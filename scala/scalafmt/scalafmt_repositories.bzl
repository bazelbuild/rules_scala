load(
    "//scala:scala_cross_version.bzl",
    _default_maven_server_urls = "default_maven_server_urls",
    _default_scala_version = "default_scala_version",
    _default_scala_version_jar_shas = "default_scala_version_jar_shas",
    _extract_major_version = "extract_major_version",
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

def _default_scala_extra_jars():
    return {
        "2.11": {
            "org_scalameta_common": {
                "version": "4.2.0",
                "sha256": "c2921b10ef2a06cafa48d4e0a6be4ff42c9135b5c5cf51ec3fdd9b66077f66cb",
            },
            "org_scalameta_fastparse": {
                "version": "1.0.1",
                "sha256": "49ecc30a4b47efc0038099da0c97515cf8f754ea631ea9f9935b36ca7d41b733",
            },
            "org_scalameta_fastparse_utils": {
                "version": "1.0.1",
                "sha256": "93f58db540e53178a686621f7a9c401307a529b68e051e38804394a2a86cea94",
            },
            "org_scalameta_parsers": {
                "version": "4.2.0",
                "sha256": "acde4faa648c61f1d76f7a1152116738c0b0b80ae2fab8ceae83c061c29aadf1",
            },
            "org_scalameta_scalafmt_core": {
                "version": "2.0.0",
                "sha256": "84bac5ed8c85e61851ef427f045b7bfd149d857cb543b41c85b8353fb8c47aff",
            },
            "org_scalameta_scalameta": {
                "version": "4.2.0",
                "sha256": "b56038c03fcad7397c571fbbc44562a3231e275aedc7a6ad15163ddcdfaed61a",
            },
            "org_scalameta_trees": {
                "version": "4.2.0",
                "sha256": "7daf84bd9a66257e42900ac940bd6df2037f09d33ca93e619ee37377d10ee34a",
            },
            "org_typelevel_paiges_core": {
                "version": "0.2.0",
                "sha256": "dec1b60448c9ac7bd4a55a4fcf68e0ce6e202d0fad1a896d4501c3ebd8052b2d",
            },
            "org_scala_lang_scalap": {
                "version": "2.11.12",
                "sha256": "a6dd7203ce4af9d6185023d5dba9993eb8e80584ff4b1f6dec574a2aba4cd2b7",
            },
            "com_thesamet_scalapb_lenses": {
                "version": "0.9.0",
                "sha256": "f4809760edee6abc97a7fe9b7fd6ae5fe1006795b1dc3963ab4e317a72f1a385",
            },
            "com_thesamet_scalapb_scalapb_runtime": {
                "version": "0.9.0",
                "sha256": "ab1e449a18a9ce411eb3fec31bdbca5dd5fae4475b1557bb5e235a7b54738757",
            },
            "com_lihaoyi_fansi": {
                "version": "0.2.5",
                "sha256": "1ff0a8304f322c1442e6bcf28fab07abf3cf560dd24573dbe671249aee5fc488",
            },
            "com_lihaoyi_fastparse": {
                "version": "2.1.2",
                "sha256": "5c5d81f90ada03ac5b21b161864a52558133951031ee5f6bf4d979e8baa03628",
            },
            "com_lihaoyi_pprint": {
                "version": "0.5.3",
                "sha256": "fb5e4921e7dff734d049e752a482d3a031380d3eea5caa76c991312dee9e6991",
            },
            "com_lihaoyi_sourcecode": {
                "version": "0.1.4",
                "sha256": "e0edffec93ddef29c40b7c65580960062a3fa9d781eddb8c64e19e707c4a8e7c",
            },
            "com_geirsson_metaconfig_core": {
                "version": "0.8.3",
                "sha256": "8abb4e48507486d0b323b440bb021bddd56366e502002025fdaf10025d2650c2",
            },
            "com_geirsson_metaconfig_typesafe_config": {
                "version": "0.8.3",
                "sha256": "410c29b2ebc842591627588d8980df507dc0eb48a0a7df312fa529fa0fe90d42",
            },
        },
        "2.12": {
            "org_scalameta_common": {
                "version": "4.2.0",
                "sha256": "6af050ec30d42bce48f9824aeb90de6ae7a8de30c400d7bfa678c91cbb12b80c",
            },
            "org_scalameta_fastparse": {
                "version": "1.0.1",
                "sha256": "387ced762e93915c5f87fed59d8453e404273f49f812d413405696ce20273aa5",
            },
            "org_scalameta_fastparse_utils": {
                "version": "1.0.1",
                "sha256": "9d8ad97778ef9aedef5d4190879ed0ec54969e2fc951576fe18746ae6ce6cfcf",
            },
            "org_scalameta_parsers": {
                "version": "4.2.0",
                "sha256": "9dc726dab95870b193dee3ed4d11985fa38ca09640768a7c86d8f80c715c5567",
            },
            "org_scalameta_scalafmt_core": {
                "version": "2.0.0",
                "sha256": "02562f176a7d070230ef2da6192f2d15afd62ea173eaf8ca02a7afb89262d233",
            },
            "org_scalameta_scalameta": {
                "version": "4.2.0",
                "sha256": "e5eabc44577f14a4bc312e5b5844592d2d53b3971d08f13974de5991ed5897f7",
            },
            "org_scalameta_trees": {
                "version": "4.2.0",
                "sha256": "af09f59540b53504686d9975dc05474dc9c3cc6dca95f7609f910929c1a33001",
            },
            "org_typelevel_paiges_core": {
                "version": "0.2.0",
                "sha256": "0051e89bfcb1efd0498c6a95cb1583bc1d097230da9627da76de0b416692e703",
            },
            "org_scala_lang_scalap": {
                "version": "2.12.10",
                "sha256": "4641b0a55fe1ebec995b4daea9183c21651c03f77d2ed08b345507474eeabe72",
            },
            "com_thesamet_scalapb_lenses": {
                "version": "0.9.0",
                "sha256": "0a2fff4de17d270cea561618090c21d50bc891d82c6f9dfccdc20568f18d0260",
            },
            "com_thesamet_scalapb_scalapb_runtime": {
                "version": "0.9.0",
                "sha256": "b905fa66b3fd0fabf3114105cd73ae2bdddbb6e13188a6538a92ae695e7ad6ed",
            },
            "com_lihaoyi_fansi": {
                "version": "0.2.5",
                "sha256": "7d752240ec724e7370903c25b69088922fa3fb6831365db845cd72498f826eca",
            },
            "com_lihaoyi_fastparse": {
                "version": "2.1.2",
                "sha256": "92a98f89c4f9559715124599ee5ce8f0d36ee326f5c7ef88b51487de39a3602e",
            },
            "com_lihaoyi_pprint": {
                "version": "0.5.3",
                "sha256": "2e18aa0884870537bf5c562255fc759d4ebe360882b5cb2141b30eda4034c71d",
            },
            "com_lihaoyi_sourcecode": {
                "version": "0.1.4",
                "sha256": "9a3134484e596205d0acdcccd260e0854346f266cb4d24e1b8a31be54fbaf6d9",
            },
            "com_geirsson_metaconfig_core": {
                "version": "0.8.3",
                "sha256": "495817d90ecb4c432ee0afa7e79b4d005e6a6f90a270e113e15fe7d2d5559dfd",
            },
            "com_geirsson_metaconfig_typesafe_config": {
                "version": "0.8.3",
                "sha256": "d9eed8472acbd4508ab25ca7bb78f1931d1d34729dfefc5f5f4c6a6e5c0aa47f",
            },
        },
    }

def scalafmt_repositories(
        scala_version_shas = (
            _default_scala_version(),
            _default_scala_version_jar_shas(),
        ),
        maven_servers = _default_maven_server_urls(),
        scala_extra_jars = _default_scala_extra_jars()):
    (scala_version, scala_version_jar_shas) = scala_version_shas
    major_version = _extract_major_version(scala_version)

    scala_version_extra_jars = scala_extra_jars[major_version]

    _scala_maven_import_external(
        name = "org_scalameta_common",
        artifact = "org.scalameta:common_{major_version}:{extra_jar_version}".format(
            major_version = major_version,
            extra_jar_version = scala_version_extra_jars["org_scalameta_common"]["version"],
        ),
        artifact_sha256 = scala_version_extra_jars["org_scalameta_common"]["sha256"],
        fetch_sources = True,
        licenses = ["notice"],  # Apache 2.0
        deps = [
            "@com_lihaoyi_sourcecode",
            "//external:io_bazel_rules_scala/dependency/scala/scala_library",
        ],
        server_urls = maven_servers,
    )

    _scala_maven_import_external(
        name = "org_scalameta_fastparse",
        artifact = "org.scalameta:fastparse_{major_version}:{extra_jar_version}".format(
            major_version = major_version,
            extra_jar_version = scala_version_extra_jars["org_scalameta_fastparse"]["version"],
        ),
        artifact_sha256 = scala_version_extra_jars["org_scalameta_fastparse"]["sha256"],
        fetch_sources = True,
        licenses = ["notice"],  # Apache 2.0
        deps = [
            "@com_lihaoyi_sourcecode",
            "//external:io_bazel_rules_scala/dependency/scala/scala_library",
            "@org_scalameta_fastparse_utils",
        ],
        server_urls = maven_servers,
    )

    _scala_maven_import_external(
        name = "org_scalameta_fastparse_utils",
        artifact = "org.scalameta:fastparse-utils_{major_version}:{extra_jar_version}".format(
            major_version = major_version,
            extra_jar_version = scala_version_extra_jars["org_scalameta_fastparse_utils"]["version"],
        ),
        artifact_sha256 = scala_version_extra_jars["org_scalameta_fastparse_utils"]["sha256"],
        fetch_sources = True,
        licenses = ["notice"],  # Apache 2.0
        deps = [
            "@com_lihaoyi_sourcecode",
            "//external:io_bazel_rules_scala/dependency/scala/scala_library",
        ],
        server_urls = maven_servers,
    )

    _scala_maven_import_external(
        name = "org_scalameta_parsers",
        artifact = "org.scalameta:parsers_{major_version}:{extra_jar_version}".format(
            major_version = major_version,
            extra_jar_version = scala_version_extra_jars["org_scalameta_parsers"]["version"],
        ),
        artifact_sha256 = scala_version_extra_jars["org_scalameta_parsers"]["sha256"],
        fetch_sources = True,
        licenses = ["notice"],  # Apache 2.0
        deps = [
            "//external:io_bazel_rules_scala/dependency/scala/scala_library",
            "@org_scalameta_trees",
        ],
        server_urls = maven_servers,
    )

    _scala_maven_import_external(
        name = "org_scalameta_scalafmt_core",
        artifact = "org.scalameta:scalafmt-core_{major_version}:{extra_jar_version}".format(
            major_version = major_version,
            extra_jar_version = scala_version_extra_jars["org_scalameta_scalafmt_core"]["version"],
        ),
        artifact_sha256 = scala_version_extra_jars["org_scalameta_scalafmt_core"]["sha256"],
        fetch_sources = True,
        licenses = ["notice"],  # Apache 2.0
        deps = [
            "@com_geirsson_metaconfig_core",
            "@com_geirsson_metaconfig_typesafe_config",
            "//external:io_bazel_rules_scala/dependency/scala/scala_library",
            "//external:io_bazel_rules_scala/dependency/scala/scala_reflect",
            "@org_scalameta_scalameta",
        ],
        server_urls = maven_servers,
    )

    _scala_maven_import_external(
        name = "org_scalameta_scalameta",
        artifact = "org.scalameta:scalameta_{major_version}:{extra_jar_version}".format(
            major_version = major_version,
            extra_jar_version = scala_version_extra_jars["org_scalameta_scalameta"]["version"],
        ),
        artifact_sha256 = scala_version_extra_jars["org_scalameta_scalameta"]["sha256"],
        fetch_sources = True,
        licenses = ["notice"],  # Apache 2.0
        deps = [
            "//external:io_bazel_rules_scala/dependency/scala/scala_library",
            "@org_scala_lang_scalap",
            "@org_scalameta_parsers",
        ],
        server_urls = maven_servers,
    )

    _scala_maven_import_external(
        name = "org_scalameta_trees",
        artifact = "org.scalameta:trees_{major_version}:{extra_jar_version}".format(
            major_version = major_version,
            extra_jar_version = scala_version_extra_jars["org_scalameta_trees"]["version"],
        ),
        artifact_sha256 = scala_version_extra_jars["org_scalameta_trees"]["sha256"],
        fetch_sources = True,
        licenses = ["notice"],  # Apache 2.0
        deps = [
            "@com_thesamet_scalapb_scalapb_runtime",
            "//external:io_bazel_rules_scala/dependency/scala/scala_library",
            "@org_scalameta_common",
            "@org_scalameta_fastparse",
        ],
        server_urls = maven_servers,
    )

    _scala_maven_import_external(
        name = "org_typelevel_paiges_core",
        artifact = "org.typelevel:paiges-core_{major_version}:{extra_jar_version}".format(
            major_version = major_version,
            extra_jar_version = scala_version_extra_jars["org_typelevel_paiges_core"]["version"],
        ),
        artifact_sha256 = scala_version_extra_jars["org_typelevel_paiges_core"]["sha256"],
        fetch_sources = True,
        licenses = ["notice"],  # Apache 2.0
        deps = [
            "//external:io_bazel_rules_scala/dependency/scala/scala_library",
        ],
        server_urls = maven_servers,
    )

    _scala_maven_import_external(
        name = "com_typesafe_config",
        artifact = "com.typesafe:config:1.3.3",
        artifact_sha256 = "b5f1d6071f1548d05be82f59f9039c7d37a1787bd8e3c677e31ee275af4a4621",
        srcjar_sha256 = "fcd7c3070417c776b313cc559665c035d74e3a2b40a89bbb0e9bff6e567c9cc8",
        fetch_sources = True,
        licenses = ["notice"],  # Apache 2.0
        server_urls = maven_servers,
    )

    _scala_maven_import_external(
        name = "org_scala_lang_scalap",
        artifact = "org.scala-lang:scalap:{extra_jar_version}".format(
            extra_jar_version = scala_version_extra_jars["org_scala_lang_scalap"]["version"],
        ),
        artifact_sha256 = scala_version_extra_jars["org_scala_lang_scalap"]["sha256"],
        fetch_sources = True,
        licenses = ["notice"],  # Apache 2.0
        deps = [
            "@io_bazel_rules_scala_scala_compiler",
        ],
        server_urls = maven_servers,
    )

    _scala_maven_import_external(
        name = "com_thesamet_scalapb_lenses",
        artifact = "com.thesamet.scalapb:lenses_{major_version}:{extra_jar_version}".format(
            major_version = major_version,
            extra_jar_version = scala_version_extra_jars["com_thesamet_scalapb_lenses"]["version"],
        ),
        artifact_sha256 = scala_version_extra_jars["com_thesamet_scalapb_lenses"]["sha256"],
        fetch_sources = True,
        licenses = ["notice"],  # Apache 2.0
        deps = [
            "//external:io_bazel_rules_scala/dependency/scala/scala_library",
        ],
        server_urls = maven_servers,
    )

    _scala_maven_import_external(
        name = "com_thesamet_scalapb_scalapb_runtime",
        artifact = "com.thesamet.scalapb:scalapb-runtime_{major_version}:{extra_jar_version}".format(
            major_version = major_version,
            extra_jar_version = scala_version_extra_jars["com_thesamet_scalapb_scalapb_runtime"]["version"],
        ),
        artifact_sha256 = scala_version_extra_jars["com_thesamet_scalapb_scalapb_runtime"]["sha256"],
        fetch_sources = True,
        licenses = ["notice"],  # Apache 2.0
        deps = [
            "@com_google_protobuf_protobuf_java",
            "@com_lihaoyi_fastparse",
            "@com_thesamet_scalapb_lenses",
            "//external:io_bazel_rules_scala/dependency/scala/scala_library",
        ],
        server_urls = maven_servers,
    )

    _scala_maven_import_external(
        name = "com_lihaoyi_fansi",
        artifact = "com.lihaoyi:fansi_{major_version}:{extra_jar_version}".format(
            major_version = major_version,
            extra_jar_version = scala_version_extra_jars["com_lihaoyi_fansi"]["version"],
        ),
        artifact_sha256 = scala_version_extra_jars["com_lihaoyi_fansi"]["sha256"],
        fetch_sources = True,
        licenses = ["notice"],  # Apache 2.0
        deps = [
            "@com_lihaoyi_sourcecode",
            "//external:io_bazel_rules_scala/dependency/scala/scala_library",
        ],
        server_urls = maven_servers,
    )

    _scala_maven_import_external(
        name = "com_lihaoyi_fastparse",
        artifact = "com.lihaoyi:fastparse_{major_version}:{extra_jar_version}".format(
            major_version = major_version,
            extra_jar_version = scala_version_extra_jars["com_lihaoyi_fastparse"]["version"],
        ),
        artifact_sha256 = scala_version_extra_jars["com_lihaoyi_fastparse"]["sha256"],
        fetch_sources = True,
        licenses = ["notice"],  # Apache 2.0
        deps = [
            "@com_lihaoyi_sourcecode",
        ],
        server_urls = maven_servers,
    )

    _scala_maven_import_external(
        name = "com_lihaoyi_pprint",
        artifact = "com.lihaoyi:pprint_{major_version}:{extra_jar_version}".format(
            major_version = major_version,
            extra_jar_version = scala_version_extra_jars["com_lihaoyi_pprint"]["version"],
        ),
        artifact_sha256 = scala_version_extra_jars["com_lihaoyi_pprint"]["sha256"],
        fetch_sources = True,
        licenses = ["notice"],  # Apache 2.0
        deps = [
            "@com_lihaoyi_fansi",
            "@com_lihaoyi_sourcecode",
            "//external:io_bazel_rules_scala/dependency/scala/scala_library",
        ],
        server_urls = maven_servers,
    )

    _scala_maven_import_external(
        name = "com_lihaoyi_sourcecode",
        artifact = "com.lihaoyi:sourcecode_{major_version}:{extra_jar_version}".format(
            major_version = major_version,
            extra_jar_version = scala_version_extra_jars["com_lihaoyi_sourcecode"]["version"],
        ),
        artifact_sha256 = scala_version_extra_jars["com_lihaoyi_sourcecode"]["sha256"],
        fetch_sources = True,
        licenses = ["notice"],  # Apache 2.0
        deps = [
            "//external:io_bazel_rules_scala/dependency/scala/scala_library",
        ],
        server_urls = maven_servers,
    )

    _scala_maven_import_external(
        name = "com_google_protobuf_protobuf_java",
        artifact = "com.google.protobuf:protobuf-java:3.10.0",
        artifact_sha256 = "161d7d61a8cb3970891c299578702fd079646e032329d6c2cabf998d191437c9",
        srcjar_sha256 = "47012b36fcd7c4325e07a3a3b43c72e1b2d7a7d79d8e2605f2327b1e81348133",
        fetch_sources = True,
        licenses = ["notice"],  # Apache 2.0
        server_urls = maven_servers,
    )

    _scala_maven_import_external(
        name = "com_geirsson_metaconfig_core",
        artifact = "com.geirsson:metaconfig-core_{major_version}:{extra_jar_version}".format(
            major_version = major_version,
            extra_jar_version = scala_version_extra_jars["com_geirsson_metaconfig_core"]["version"],
        ),
        artifact_sha256 = scala_version_extra_jars["com_geirsson_metaconfig_core"]["sha256"],
        fetch_sources = True,
        licenses = ["notice"],  # Apache 2.0
        deps = [
            "@com_lihaoyi_pprint",
            "//external:io_bazel_rules_scala/dependency/scala/scala_library",
            "@org_typelevel_paiges_core",
        ],
        server_urls = maven_servers,
    )

    _scala_maven_import_external(
        name = "com_geirsson_metaconfig_typesafe_config",
        artifact = "com.geirsson:metaconfig-typesafe-config_{major_version}:{extra_jar_version}".format(
            major_version = major_version,
            extra_jar_version = scala_version_extra_jars["com_geirsson_metaconfig_typesafe_config"]["version"],
        ),
        artifact_sha256 = scala_version_extra_jars["com_geirsson_metaconfig_typesafe_config"]["sha256"],
        fetch_sources = True,
        licenses = ["notice"],  # Apache 2.0
        deps = [
            "@com_geirsson_metaconfig_core",
            "@com_typesafe_config",
            "//external:io_bazel_rules_scala/dependency/scala/scala_library",
        ],
        server_urls = maven_servers,
    )
