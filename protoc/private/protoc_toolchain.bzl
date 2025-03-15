"""Prepares the precompiled protoc toolchain"""

load(":private/protoc_integrity.bzl", "PROTOC_BUILDS", "PROTOC_DOWNLOAD_URL")
load("@com_google_protobuf//:protobuf_version.bzl", "PROTOC_VERSION")
load("@com_google_protobuf//bazel/common:proto_common.bzl", "proto_common")
load("@platforms//host:constraints.bzl", "HOST_CONSTRAINTS")

def _default_platform():
    host_platform = sorted(HOST_CONSTRAINTS)
    for platform, info in PROTOC_BUILDS.items():
        if sorted(info["exec_compat"]) == host_platform:
            return platform
    fail(
        "no protoc build found for host platform with constraints: " +
        HOST_CONSTRAINTS,
    )

def _platform_build(platform):
    if platform not in PROTOC_BUILDS:
        fail("no protoc build found for platform: " + platform)

    protoc_build = PROTOC_BUILDS[platform]

    if PROTOC_VERSION not in protoc_build["integrity"]:
        fail(
            "no protoc %s build found for platform: %s" %
            (PROTOC_VERSION, platform),
        )
    return protoc_build

def _download_build(repository_ctx, package, platform, protoc_build):
    repository_ctx.download_and_extract(
        url = PROTOC_DOWNLOAD_URL.format(
            platform = platform,
            version = PROTOC_VERSION,
        ),
        output = "%s/%s" % (package, platform),
        integrity = protoc_build["integrity"][PROTOC_VERSION],
    )

def _emit_platform_entry(platform, protoc_build):
    return '    "{platform}": [\n{specs}\n    ],'.format(
        platform = platform,
        specs = "\n".join([
            '        "%s",' % s
            for s in protoc_build["exec_compat"]
        ]),
    )

def _generate_protoc_platforms(repository_ctx, package, builds):
    content = ["PROTOC_PLATFORMS = {"]
    content.extend([_emit_platform_entry(p, b) for p, b in builds])
    content.append("}\n")

    repository_ctx.file(
        package + "/platforms.bzl",
        content = "\n".join(content),
        executable = False,
    )

def setup_protoc_toolchains(repository_ctx, package):
    builds = []
    build_file_content = ""

    if proto_common.INCOMPATIBLE_ENABLE_PROTO_TOOLCHAIN_RESOLUTION:
        platforms = [_default_platform()]
        platforms += repository_ctx.attr.protoc_platforms
        builds = {p: _platform_build(p) for p in platforms}.items()
        build_file_content = _PROTOC_TOOLCHAIN_BUILD

    for platform, build in builds:
        _download_build(repository_ctx, package, platform, build)

    _generate_protoc_platforms(repository_ctx, package, builds)

    repository_ctx.file(
        package + "/BUILD",
        content = build_file_content,
        executable = False,
    )

_PROTOC_TOOLCHAIN_BUILD = """
load(":platforms.bzl", "PROTOC_PLATFORMS")
load("@rules_proto//proto:defs.bzl", "proto_lang_toolchain")

toolchain_type(
    name = "toolchain_type",
    visibility = ["//visibility:public"],
)

proto_lang_toolchain(
    name = "protoc_scala_toolchain",
    command_line = "unused-because-we-pass-protoc-to-scalapb",
    toolchain_type = ":toolchain_type",
)

[
    alias(
        name = platform,
        actual = ":%s/bin/protoc%s" % (
            platform, ".exe" if platform.startswith("win") else ""
        ),
        visibility = ["//visibility:public"],
    )
    for platform in PROTOC_PLATFORMS
]
"""
