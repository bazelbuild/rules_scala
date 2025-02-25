load("//scala:providers.bzl", _DepsInfo = "DepsInfo")
load("//scala/private/toolchain_deps:toolchain_deps.bzl", "expose_toolchain_deps")

SCALAFMT_TOOLCHAIN_TYPE = Label(
    "//scala/scalafmt/toolchain:scalafmt_toolchain_type",
)

def _scalafmt_toolchain_impl(ctx):
    toolchain = platform_common.ToolchainInfo(
        dep_providers = ctx.attr.dep_providers,
    )
    return [toolchain]

scalafmt_toolchain = rule(
    _scalafmt_toolchain_impl,
    attrs = {
        "dep_providers": attr.label_list(providers = [_DepsInfo]),
    },
)

def _export_scalafmt_deps_impl(ctx):
    return expose_toolchain_deps(ctx, SCALAFMT_TOOLCHAIN_TYPE)

export_scalafmt_deps = rule(
    _export_scalafmt_deps_impl,
    attrs = {
        "deps_id": attr.string(
            mandatory = True,
        ),
    },
    toolchains = [SCALAFMT_TOOLCHAIN_TYPE],
)
