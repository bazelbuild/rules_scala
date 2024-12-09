load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")
load(
    "@rules_java//toolchains:remote_java_repository.bzl",
    "remote_java_repository",
)

def remote_jdk21_repositories():
    maybe(
        remote_java_repository,
        name = "remotejdk21_linux",
        target_compatible_with = [
            "@platforms//os:linux",
            "@platforms//cpu:x86_64",
        ],
        sha256 = "5ad730fbee6bb49bfff10bf39e84392e728d89103d3474a7e5def0fd134b300a",
        strip_prefix = "zulu21.32.17-ca-jdk21.0.2-linux_x64",
        urls = [
            "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu21.32.17-ca-jdk21.0.2-linux_x64.tar.gz",
            "https://cdn.azul.com/zulu/bin/zulu21.32.17-ca-jdk21.0.2-linux_x64.tar.gz",
        ],
        version = "21",
    )

    maybe(
        remote_java_repository,
        name = "remotejdk21_macos",
        target_compatible_with = [
            "@platforms//os:macos",
            "@platforms//cpu:x86_64",
        ],
        sha256 = "3ad8fe288eb57d975c2786ae453a036aa46e47ab2ac3d81538ebae2a54d3c025",
        strip_prefix = "zulu21.32.17-ca-jdk21.0.2-macosx_x64",
        urls = [
            "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu21.32.17-ca-jdk21.0.2-macosx_x64.tar.gz",
            "https://cdn.azul.com/zulu/bin/zulu21.32.17-ca-jdk21.0.2-macosx_x64.tar.gz",
        ],
        version = "21",
    )

    maybe(
        remote_java_repository,
        name = "remotejdk21_win",
        target_compatible_with = [
            "@platforms//os:windows",
            "@platforms//cpu:x86_64",
        ],
        sha256 = "f7cc15ca17295e69c907402dfe8db240db446e75d3b150da7bf67243cded93de",
        strip_prefix = "zulu21.32.17-ca-jdk21.0.2-win_x64",
        urls = [
            "https://mirror.bazel.build/cdn.azul.com/zulu/bin/zulu21.32.17-ca-jdk21.0.2-win_x64.zip",
            "https://cdn.azul.com/zulu/bin/zulu21.32.17-ca-jdk21.0.2-win_x64.zip",
        ],
        version = "21",
    )

def remote_jdk21_toolchains():
    native.register_toolchains("//test/toolchains:java21_toolchain_definition")
