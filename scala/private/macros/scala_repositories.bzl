load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load(
    "@io_bazel_rules_scala//scala:scala_cross_version.bzl",
    _default_maven_server_urls = "default_maven_server_urls",
)
load("//third_party/repositories:repositories.bzl", "repositories")
load("@io_bazel_rules_scala_config//:config.bzl", "SCALA_MAJOR_VERSION")

def rules_scala_setup():
    if not native.existing_rule("bazel_skylib"):
        skylib_version = "1.0.3"
        http_archive(
            name = "bazel_skylib",
            sha256 = "1c531376ac7e5a180e0237938a2536de0c54d93f5c278634818e0efc952dd56c",
            type = "tar.gz",
            url = "https://mirror.bazel.build/github.com/bazelbuild/bazel-skylib/releases/download/{}/bazel-skylib-{}.tar.gz".format(skylib_version, skylib_version),
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
            url = "https://github.com/bazelbuild/rules_java/releases/download/3.7.2/rules_java-3.7.2.tar.gz",
            sha256 = "b2fd0bb9327287edd388f80d842d5c1e90abfed2e17ed4fe8cb0e83650e8d918",
        )

    if not native.existing_rule("rules_proto"):
        http_archive(
            name = "rules_proto",
            sha256 = "8e7d59a5b12b233be5652e3d29f42fba01c7cbab09f6b3a8d0a57ed6d1e9a0da",
            strip_prefix = "rules_proto-7e4afce6fe62dbff0a4a03450143146f9f2d7488",
            urls = [
                "https://mirror.bazel.build/github.com/bazelbuild/rules_proto/archive/7e4afce6fe62dbff0a4a03450143146f9f2d7488.tar.gz",
                "https://github.com/bazelbuild/rules_proto/archive/7e4afce6fe62dbff0a4a03450143146f9f2d7488.tar.gz",
            ],
        )

ARTIFACT_IDS = [
    "io_bazel_rules_scala_scala_library",
    "io_bazel_rules_scala_scala_compiler",
    "io_bazel_rules_scala_scala_reflect",
    "io_bazel_rules_scala_scalatest",
    "io_bazel_rules_scala_scalactic",
    "io_bazel_rules_scala_scala_xml",
    "io_bazel_rules_scala_scala_parser_combinators",
] if SCALA_MAJOR_VERSION.startswith("2") else [
    "io_bazel_rules_scala_scala_library",
    "io_bazel_rules_scala_scala_compiler",
    "io_bazel_rules_scala_scala_interfaces",
    "io_bazel_rules_scala_scala_tasty_core",
    "io_bazel_rules_scala_scala_asm",
    "io_bazel_rules_scala_scalatest",
    "io_bazel_rules_scala_scalactic",
    "io_bazel_rules_scala_scala_xml",
    "io_bazel_rules_scala_scala_parser_combinators",
    "io_bazel_rules_scala_scala_library_2",
]

def scala_repositories(
        maven_servers = _default_maven_server_urls(),
        overriden_artifacts = {},
        load_dep_rules = True,
        load_jar_deps = True,
        fetch_sources = False):
    if load_dep_rules:
        rules_scala_setup()

    if load_jar_deps:
        repositories(
            for_artifact_ids = ARTIFACT_IDS,
            maven_servers = maven_servers,
            fetch_sources = fetch_sources,
            overriden_artifacts = overriden_artifacts,
        )
