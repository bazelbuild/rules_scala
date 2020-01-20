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

def scalafmt_repositories(maven_servers = ["https://repo.maven.apache.org/maven2"]):
    _scala_maven_import_external(
        name = "com_geirsson_metaconfig_core_2_11",
        artifact = "com.geirsson:metaconfig-core_2.11:0.8.3",
        artifact_sha256 = "8abb4e48507486d0b323b440bb021bddd56366e502002025fdaf10025d2650c2",
        licenses = ["notice"],
        server_urls = maven_servers,
    )

    _scala_maven_import_external(
        name = "org_scalameta_common_2_11",
        artifact = "org.scalameta:common_2.11:4.2.0",
        artifact_sha256 = "c2921b10ef2a06cafa48d4e0a6be4ff42c9135b5c5cf51ec3fdd9b66077f66cb",
        srcjar_sha256 = "373ee3a734ae1ca8cb3361812f0702ed52d5d2fbff95e7406752be408a2d9a59",
        fetch_sources = True,
        licenses = ["notice"],  # Apache 2.0
        deps = [
            "@com_lihaoyi_sourcecode_2_11",
            "//external:io_bazel_rules_scala/dependency/scala/scala_library",
        ],
        server_urls = maven_servers,
    )

    _scala_maven_import_external(
        name = "org_scalameta_fastparse_2_11",
        artifact = "org.scalameta:fastparse_2.11:1.0.1",
        artifact_sha256 = "49ecc30a4b47efc0038099da0c97515cf8f754ea631ea9f9935b36ca7d41b733",
        srcjar_sha256 = "9769781eeb2980be3379c2cf6aced31f60ad32fe903a830687185e9ffc223d84",
        fetch_sources = True,
        licenses = ["notice"],  # Apache 2.0
        deps = [
            "@com_lihaoyi_sourcecode_2_11",
            "//external:io_bazel_rules_scala/dependency/scala/scala_library",
            "@org_scalameta_fastparse_utils_2_11",
        ],
        server_urls = maven_servers,
    )

    _scala_maven_import_external(
        name = "org_scalameta_fastparse_utils_2_11",
        artifact = "org.scalameta:fastparse-utils_2.11:1.0.1",
        artifact_sha256 = "93f58db540e53178a686621f7a9c401307a529b68e051e38804394a2a86cea94",
        srcjar_sha256 = "f1c28e408d8309f6f96ea9ed0f2e0bc5661fb84d3730d1bde06207a93a3d091b",
        fetch_sources = True,
        licenses = ["notice"],  # Apache 2.0
        deps = [
            "@com_lihaoyi_sourcecode_2_11",
            "//external:io_bazel_rules_scala/dependency/scala/scala_library",
        ],
        server_urls = maven_servers,
    )

    _scala_maven_import_external(
        name = "org_scalameta_parsers_2_11",
        artifact = "org.scalameta:parsers_2.11:4.2.0",
        artifact_sha256 = "acde4faa648c61f1d76f7a1152116738c0b0b80ae2fab8ceae83c061c29aadf1",
        srcjar_sha256 = "212e7e9070c80fbba4680f6d0355036b6486189289515a52b013d36c6070ff1a",
        fetch_sources = True,
        licenses = ["notice"],  # Apache 2.0
        deps = [
            "//external:io_bazel_rules_scala/dependency/scala/scala_library",
            "@org_scalameta_trees_2_11",
        ],
        server_urls = maven_servers,
    )

    _scala_maven_import_external(
        name = "org_scalameta_scalafmt_core_2_11",
        artifact = "org.scalameta:scalafmt-core_2.11:2.0.0",
        artifact_sha256 = "84bac5ed8c85e61851ef427f045b7bfd149d857cb543b41c85b8353fb8c47aff",
        srcjar_sha256 = "6ea863beba530b8eabbb648143387f5ccba6299d0fc331046ab30dc493c984ca",
        fetch_sources = True,
        licenses = ["notice"],  # Apache 2.0
        deps = [
            "@com_geirsson_metaconfig_core_2_11",
            "@com_geirsson_metaconfig_typesafe_config_2_11",
            "//external:io_bazel_rules_scala/dependency/scala/scala_library",
            "//external:io_bazel_rules_scala/dependency/scala/scala_reflect",
            "@org_scalameta_scalameta_2_11",
        ],
        server_urls = maven_servers,
    )

    _scala_maven_import_external(
        name = "org_scalameta_scalameta_2_11",
        artifact = "org.scalameta:scalameta_2.11:4.2.0",
        artifact_sha256 = "b56038c03fcad7397c571fbbc44562a3231e275aedc7a6ad15163ddcdfaed61a",
        srcjar_sha256 = "fa57cb1b1800dee3dee970250012ebf1f95b7a3f6ee7b26c7d3dd0df971ac1cb",
        fetch_sources = True,
        licenses = ["notice"],  # Apache 2.0
        deps = [
            "//external:io_bazel_rules_scala/dependency/scala/scala_library",
            "@org_scala_lang_scalap",
            "@org_scalameta_parsers_2_11",
        ],
        server_urls = maven_servers,
    )

    _scala_maven_import_external(
        name = "org_scalameta_trees_2_11",
        artifact = "org.scalameta:trees_2.11:4.2.0",
        artifact_sha256 = "7daf84bd9a66257e42900ac940bd6df2037f09d33ca93e619ee37377d10ee34a",
        srcjar_sha256 = "13a8be06f350100754cff19c776b2d03b954677b816c0e4888752845480be358",
        fetch_sources = True,
        licenses = ["notice"],  # Apache 2.0
        deps = [
            "@com_thesamet_scalapb_scalapb_runtime_2_11",
            "//external:io_bazel_rules_scala/dependency/scala/scala_library",
            "@org_scalameta_common_2_11",
            "@org_scalameta_fastparse_2_11",
        ],
        server_urls = maven_servers,
    )

    _scala_maven_import_external(
        name = "org_typelevel_paiges_core_2_11",
        artifact = "org.typelevel:paiges-core_2.11:0.2.0",
        artifact_sha256 = "dec1b60448c9ac7bd4a55a4fcf68e0ce6e202d0fad1a896d4501c3ebd8052b2d",
        srcjar_sha256 = "952fd039b04e06cc52daf2f8232e5b3adc2009bf287a688e4c82edf3cc37d3d0",
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
        artifact = "org.scala-lang:scalap:2.11.12",
        artifact_sha256 = "a6dd7203ce4af9d6185023d5dba9993eb8e80584ff4b1f6dec574a2aba4cd2b7",
        srcjar_sha256 = "50df9e4b4c996cda761f35cbc603cf145a21157a72a82d023d44b0eeeb293e29",
        fetch_sources = True,
        licenses = ["notice"],  # Apache 2.0
        deps = [
            "@io_bazel_rules_scala_scala_compiler",
        ],
        server_urls = maven_servers,
    )

    _scala_maven_import_external(
        name = "com_thesamet_scalapb_lenses_2_11",
        artifact = "com.thesamet.scalapb:lenses_2.11:0.9.0",
        artifact_sha256 = "f4809760edee6abc97a7fe9b7fd6ae5fe1006795b1dc3963ab4e317a72f1a385",
        srcjar_sha256 = "57753e022b607b63a4f60a4570fbd1e524ffc76f389a444033cdea5e83424402",
        fetch_sources = True,
        licenses = ["notice"],  # Apache 2.0
        deps = [
            "//external:io_bazel_rules_scala/dependency/scala/scala_library",
        ],
        server_urls = maven_servers,
    )

    _scala_maven_import_external(
        name = "com_thesamet_scalapb_scalapb_runtime_2_11",
        artifact = "com.thesamet.scalapb:scalapb-runtime_2.11:0.9.0",
        artifact_sha256 = "ab1e449a18a9ce411eb3fec31bdbca5dd5fae4475b1557bb5e235a7b54738757",
        srcjar_sha256 = "41d3c78eac7f4cadc9a785539a29730aa78432b110975ab857656804b4ca0344",
        fetch_sources = True,
        licenses = ["notice"],  # Apache 2.0
        deps = [
            "@com_google_protobuf_protobuf_java",
            "@com_lihaoyi_fastparse_2_11",
            "@com_thesamet_scalapb_lenses_2_11",
            "//external:io_bazel_rules_scala/dependency/scala/scala_library",
        ],
        server_urls = maven_servers,
    )

    _scala_maven_import_external(
        name = "com_lihaoyi_fansi_2_11",
        artifact = "com.lihaoyi:fansi_2.11:0.2.5",
        artifact_sha256 = "1ff0a8304f322c1442e6bcf28fab07abf3cf560dd24573dbe671249aee5fc488",
        srcjar_sha256 = "960df264aac81442d68bfdee9385a8af3e38e979bd568a3f9477de9e978f6d24",
        fetch_sources = True,
        licenses = ["notice"],  # Apache 2.0
        deps = [
            "@com_lihaoyi_sourcecode_2_11",
            "//external:io_bazel_rules_scala/dependency/scala/scala_library",
        ],
        server_urls = maven_servers,
    )

    _scala_maven_import_external(
        name = "com_lihaoyi_fastparse_2_11",
        artifact = "com.lihaoyi:fastparse_2.11:2.1.2",
        artifact_sha256 = "5c5d81f90ada03ac5b21b161864a52558133951031ee5f6bf4d979e8baa03628",
        srcjar_sha256 = "1f4509b44b9de440400b949993277d22440033bf42425f93f5b13b94dc41f63b",
        fetch_sources = True,
        licenses = ["notice"],  # Apache 2.0
        deps = [
            "@com_lihaoyi_sourcecode_2_11",
        ],
        server_urls = maven_servers,
    )

    _scala_maven_import_external(
        name = "com_lihaoyi_pprint_2_11",
        artifact = "com.lihaoyi:pprint_2.11:0.5.3",
        artifact_sha256 = "fb5e4921e7dff734d049e752a482d3a031380d3eea5caa76c991312dee9e6991",
        srcjar_sha256 = "99bf854d4e5495161ec9bc6d3bb8d0c274973c0f7c607151c4848c1f85b6c82e",
        fetch_sources = True,
        licenses = ["notice"],  # Apache 2.0
        deps = [
            "@com_lihaoyi_fansi_2_11",
            "@com_lihaoyi_sourcecode_2_11",
            "//external:io_bazel_rules_scala/dependency/scala/scala_library",
        ],
        server_urls = maven_servers,
    )

    _scala_maven_import_external(
        name = "com_lihaoyi_sourcecode_2_11",
        artifact = "com.lihaoyi:sourcecode_2.11:0.1.4",
        artifact_sha256 = "e0edffec93ddef29c40b7c65580960062a3fa9d781eddb8c64e19e707c4a8e7c",
        srcjar_sha256 = "b6a282beaca27092692197c017cbd349dccf526100af1bbd7f78cf462219f7f9",
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
        name = "com_geirsson_metaconfig_core_2_11",
        artifact = "com.geirsson:metaconfig-core_2.11:0.8.3",
        artifact_sha256 = "8abb4e48507486d0b323b440bb021bddd56366e502002025fdaf10025d2650c2",
        srcjar_sha256 = "5a4a2e1ec9153f79ae2747172b1ec4596b8a7788c7ac7bc3aed2b698dc0594a1",
        fetch_sources = True,
        licenses = ["notice"],  # Apache 2.0
        deps = [
            "@com_lihaoyi_pprint_2_11",
            "//external:io_bazel_rules_scala/dependency/scala/scala_library",
            "@org_typelevel_paiges_core_2_11",
        ],
        server_urls = maven_servers,
    )

    _scala_maven_import_external(
        name = "com_geirsson_metaconfig_typesafe_config_2_11",
        artifact = "com.geirsson:metaconfig-typesafe-config_2.11:0.8.3",
        artifact_sha256 = "410c29b2ebc842591627588d8980df507dc0eb48a0a7df312fa529fa0fe90d42",
        srcjar_sha256 = "494109a773bb4470cb2f2b31831eb7582acbf30e1f0db3a88362f69ebd55a854",
        fetch_sources = True,
        licenses = ["notice"],  # Apache 2.0
        deps = [
            "@com_geirsson_metaconfig_core_2_11",
            "@com_typesafe_config",
            "//external:io_bazel_rules_scala/dependency/scala/scala_library",
        ],
        server_urls = maven_servers,
    )

    _scala_maven_import_external(
        name = "net_sourceforge_argparse4j_argparse4j",
        artifact = "net.sourceforge.argparse4j:argparse4j:0.8.1",
        artifact_sha256 = "98cb5468cac609f3bc07856f2e34088f50dc114181237c48d20ca69c3265d044",
        licenses = ["notice"],
        server_urls = maven_servers,
    )
