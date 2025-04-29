"""Precompiled protoc toolchains repo rule

Provides precompiled protocol compiler toolchains.
"""

load(":private/protoc_integrity.bzl", "PROTOC_BUILDS", "PROTOC_DOWNLOAD_URL")
load(
    ":private/toolchain_impl.bzl",
    "PROTOC_TOOLCHAIN_ENABLED",
    "PROTOC_TOOLCHAIN_TYPE",
)
load("@com_google_protobuf//:protobuf_version.bzl", "PROTOC_VERSION")
load("@platforms//host:constraints.bzl", "HOST_CONSTRAINTS")

def _default_platform():
    host_platform = sorted(HOST_CONSTRAINTS)
    for platform, info in PROTOC_BUILDS.items():
        if sorted(info["exec_compat"]) == host_platform:
            return platform

    # Temporary measure until native Windows ARM64 builds exist.
    if host_platform == ["@platforms//cpu:aarch64", "@platforms//os:windows"]:
        return "win64"

    fail(
        "no protoc build found for host platform with constraints: " +
        ", ".join(HOST_CONSTRAINTS),
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

def _download_build(repository_ctx, platform, protoc_build):
    repository_ctx.download_and_extract(
        url = PROTOC_DOWNLOAD_URL.format(
            platform = platform,
            version = PROTOC_VERSION,
        ),
        output = platform,
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

def _generate_protoc_platforms(repository_ctx, builds):
    content = ["PROTOC_PLATFORMS = {"]
    content.extend([_emit_platform_entry(p, b) for p, b in builds])
    content.append("}\n")

    repository_ctx.file(
        "platforms.bzl",
        content = "\n".join(content),
        executable = False,
    )

def _scala_protoc_toolchains_impl(repository_ctx):
    builds = []
    build_file_content = ""

    if PROTOC_TOOLCHAIN_ENABLED:
        platforms = [_default_platform()]
        platforms += repository_ctx.attr.platforms
        builds = {p: _platform_build(p) for p in platforms}.items()
        build_file_content = _PROTOC_TOOLCHAIN_BUILD

    for platform, build in builds:
        _download_build(repository_ctx, platform, build)

    _generate_protoc_platforms(repository_ctx, builds)

    # Always generate a root package, even if it's empty, to ensure
    # `register_toolchains("@rules_scala_protoc_toolchains//:all")` works.
    repository_ctx.file(
        "BUILD",
        content = build_file_content,
        executable = False,
    )

scala_protoc_toolchains = repository_rule(
    implementation = _scala_protoc_toolchains_impl,
    doc = (
        "Prepares the precompiled protoc toolchain used by " +
        "`--incompatible_enable_proto_toolchain_resolution`"
    ),
    attrs = {
        "platforms": attr.string_list(
            doc = (
                "Operating system and architecture identifiers for " +
                "precompiled protocol compiler releases, taken from " +
                "protocolbuffers/protobuf releases file name suffixes. If " +
                "unspecified, will use the identifier matching the " +
                "`HOST_CONSTRAINTS` from `@platforms//host:constraints.bzl`." +
                " Only takes effect when" +
                "`--incompatible_enable_proto_toolchain_resolution` is " +
                "`True`."
            ),
        ),
    },
)

_PROTOC_TOOLCHAIN_BUILD = """load(":platforms.bzl", "PROTOC_PLATFORMS")
load(
    "@com_google_protobuf//bazel/toolchains:proto_lang_toolchain.bzl",
    "proto_lang_toolchain",
)
load(
    "@com_google_protobuf//bazel/toolchains:proto_toolchain.bzl",
    "proto_toolchain",
)

proto_lang_toolchain(
    name = "protoc_scala_toolchain",
    command_line = "unused-because-we-pass-protoc-to-scalapb",
    toolchain_type = "{protoc_toolchain_type}",
    visibility = ["//visibility:public"],
)

[
    proto_toolchain(
        name = platform,
        exec_compatible_with = specs,
        proto_compiler = ":%s/bin/protoc%s" % (
            platform, ".exe" if platform.startswith("win") else ""
        ),
    )
    for platform, specs in PROTOC_PLATFORMS.items()
]
""".format(protoc_toolchain_type = PROTOC_TOOLCHAIN_TYPE)
