"""Precompiled protoc toolchain utilities

Implements `--incompatible_enable_proto_toolchain_resolution` compatibility to
provide a precompiled protocol compiler toolchain.
"""

load(":private/protoc_integrity.bzl", "PROTOC_BUILDS", "PROTOC_DOWNLOAD_URL")
load("@com_google_protobuf//:protobuf_version.bzl", "PROTOC_VERSION")
load("@platforms//host:constraints.bzl", "HOST_CONSTRAINTS")
load("@rules_proto//proto:proto_common.bzl", "toolchains")

PROTOC_ATTR = toolchains.if_legacy_toolchain({
    "protoc": attr.label(
        allow_files = True,
        cfg = "exec",
        default = Label("@com_google_protobuf//:protoc"),
        executable = True,
    ),
})
PROTOC_TOOLCHAIN_TYPE = Label("//protoc:toolchain_type")
PROTOC_TOOLCHAINS = toolchains.use_toolchain(PROTOC_TOOLCHAIN_TYPE)

_PROTOC_TOOLCHAIN_ENABLED = not bool(toolchains.if_legacy_toolchain(True))

# Inspired by: https://github.com/protocolbuffers/protobuf/pull/19679
def protoc_executable(ctx):
    """Returns `protoc` executable path for rules using `PROTOC_*` symbols.

    Requires that rules use `PROTOC_ATTR` and `PROTOC_TOOLCHAINS` as follows:

    ```py
    attrs = {
        # ...other attrs...
    } | PROTOC_ATTR,
    toolchains = PROTOC_TOOLCHAINS,
    ```

    Args:
        ctx: the rule context object

    Returns:
        the precompiled `protoc` executable path from the precompiled toolchain
        if `--incompatible_enable_proto_toolchain_resolution` is enabled,
        or the path to the `protoc` compiled by `protobuf` otherwise
    """
    if not _PROTOC_TOOLCHAIN_ENABLED:
        return ctx.attr.protoc[DefaultInfo].files_to_run.executable

    toolchain = ctx.toolchains[PROTOC_TOOLCHAIN_TYPE]
    if not toolchain:
        fail("Couldn't resolve protocol compiler for " + PROTOC_TOOLCHAIN_TYPE)
    return toolchain.proto.proto_compiler.executable

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

ENABLE_PROTOC_TOOLCHAIN_ATTR = "INCOMPATIBLE_ENABLE_PROTO_TOOLCHAIN_RESOLUTION"

def _scala_protoc_toolchains_impl(repository_ctx):
    builds = []
    build_file_content = ""

    if _PROTOC_TOOLCHAIN_ENABLED:
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
