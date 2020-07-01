load("@io_bazel_rules_scala//scala:providers.bzl", "DepsInfo")

def _deps_toolchain(ctx):
    toolchain_info = platform_common.ToolchainInfo(
        dep_providers = ctx.attr.dep_providers,
    )
    return [toolchain_info]

declare_deps_toolchain = rule(
    attrs = {
        "dep_providers": attr.label_keyed_string_dict(
            providers = [DepsInfo],
        ),
    },
    implementation = _deps_toolchain,
)
