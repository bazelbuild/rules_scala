"""Macro for instantiating repos required for core functionality."""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")

def rules_scala_dependencies():
    """Instantiates repos needed by rules provided by `rules_scala`."""
    maybe(
        http_archive,
        name = "bazel_skylib",
        sha256 = "41449d7c7372d2e270e8504dfab09ee974325b0b40fdd98172c7fbe257b8bcc9",
        urls = [
            "https://mirror.bazel.build/github.com/bazelbuild/bazel-skylib/releases/download/1.6.0/bazel-skylib-1.6.0.tar.gz",
            "https://github.com/bazelbuild/bazel-skylib/releases/download/1.6.0/bazel-skylib-1.6.0.tar.gz",
        ],
    )

    maybe(
        http_archive,
        name = "platforms",
        urls = [
            "https://mirror.bazel.build/github.com/bazelbuild/platforms/releases/download/0.0.9/platforms-0.0.9.tar.gz",
            "https://github.com/bazelbuild/platforms/releases/download/0.0.9/platforms-0.0.9.tar.gz",
        ],
        sha256 = "5eda539c841265031c2f82d8ae7a3a6490bd62176e0c038fc469eabf91f6149b",
    )

    # If using `rules_java` between 7.6.0 and 8.4.0, the `WORKSPACE` statements
    # are different. See:
    # - https://github.com/bazelbuild/rules_java/releases/tag/7.6.0
    #maybe(
    #    http_archive,
    #    name = "rules_java",
    #    urls = [
    #        "https://github.com/bazelbuild/rules_java/releases/download/7.6.0/rules_java-7.6.0.tar.gz",
    #    ],
    #    sha256 = "1da22389fe688c515ed732d01a2b18f3961eb4431aec40dcbaa043b58ba7941e",
    #)

    maybe(
        http_archive,
        name = "rules_java",
        urls = [
            "https://github.com/bazelbuild/rules_java/releases/download/8.5.0/rules_java-8.5.0.tar.gz",
        ],
        sha256 = "5c215757b9a6c3dd5312a3cdc4896cef3f0c5b31db31baa8da0d988685d42ae4",
    )

    maybe(
        http_archive,
        name = "com_google_protobuf",
        sha256 = "b2340aa47faf7ef10a0328190319d3f3bee1b24f426d4ce8f4253b6f27ce16db",
        strip_prefix = "protobuf-28.2",
        url = "https://github.com/protocolbuffers/protobuf/archive/refs/tags/v28.2.tar.gz",
    )

    # The `WORKSPACE` snippets for different versions of `rules_proto` vary
    # somewhat. See https://github.com/bazelbuild/rules_proto/releases for the
    # corresponding `rules_proto` release for details.
    maybe(
        http_archive,
        name = "rules_proto",
        sha256 = "6fb6767d1bef535310547e03247f7518b03487740c11b6c6adb7952033fe1295",
        strip_prefix = "rules_proto-6.0.2",
        url = "https://github.com/bazelbuild/rules_proto/releases/download/6.0.2/rules_proto-6.0.2.tar.gz",
    )
