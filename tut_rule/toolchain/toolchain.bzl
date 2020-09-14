load("@io_bazel_rules_scala//scala:providers.bzl", _DepsInfo = "DepsInfo")
load("//scala/private/toolchain_deps:toolchain_deps.bzl", "expose_toolchain_deps")

def _tut_toolchain_impl(ctx):
    toolchain = platform_common.ToolchainInfo(
        dep_providers = ctx.attr.dep_providers,
    )

    return [toolchain]

tut_toolchain = rule(
    _tut_toolchain_impl,
    attrs = {
        "dep_providers": attr.label_list(
            default = [
                "@io_bazel_rules_scala//tut_rule:tut_core_provider",
            ],
            providers = [_DepsInfo],
        ),
    },
)

def _export_tut_deps(ctx):
    return expose_toolchain_deps(
        ctx,
        "@io_bazel_rules_scala//tut_rule/toolchain:tut_toolchain_type",
    )

export_tut_deps = rule(
    _export_tut_deps,
    attrs = {
        "deps_id": attr.string(
            mandatory = True,
        ),
    },
    toolchains = ["@io_bazel_rules_scala//tut_rule/toolchain:tut_toolchain_type"],
)
