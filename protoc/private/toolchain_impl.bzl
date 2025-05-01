"""Precompiled protoc toolchain utilities

Used to implement `--incompatible_enable_proto_toolchain_resolution`
compatibility. Inspired by:
https://github.com/protocolbuffers/protobuf/pull/19679
"""

load("@rules_proto//proto:proto_common.bzl", "toolchains")

PROTOC_TOOLCHAIN_ENABLED = not bool(toolchains.if_legacy_toolchain(True))
PROTOC_TOOLCHAIN_TYPE = Label("//protoc:toolchain_type")

PROTOC_ATTR = toolchains.if_legacy_toolchain({
    "protoc": attr.label(
        allow_files = True,
        cfg = "exec",
        default = Label("@com_google_protobuf//:protoc"),
        executable = True,
    ),
})
PROTOC_TOOLCHAINS = toolchains.use_toolchain(PROTOC_TOOLCHAIN_TYPE)

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
    if not PROTOC_TOOLCHAIN_ENABLED:
        return ctx.attr.protoc[DefaultInfo].files_to_run.executable

    toolchain = ctx.toolchains[PROTOC_TOOLCHAIN_TYPE]
    if not toolchain:
        fail("Couldn't resolve protocol compiler for " + PROTOC_TOOLCHAIN_TYPE)
    return toolchain.proto.proto_compiler.executable
