load("//scala:providers.bzl", _DepsInfo = "DepsInfo")

def _scala_toolchain_impl(ctx):
    toolchain = platform_common.ToolchainInfo(
        dep_providers = ctx.attr.dep_providers,
    )
    return [toolchain]

scala_testing_toolchain = rule(
    _scala_toolchain_impl,
    attrs = {
        "dep_providers": attr.label_list(
            providers = [_DepsInfo],
        ),
    },
)
