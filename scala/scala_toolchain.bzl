load(
    "@io_bazel_rules_scala//scala:providers.bzl",
    _ScalacProvider = "ScalacProvider",
)

def _scala_toolchain_impl(ctx):
    toolchain = platform_common.ToolchainInfo(
        scalacopts = ctx.attr.scalacopts,
        scalac_provider_attr = ctx.attr.scalac_provider_attr,
        unused_dependency_checker_mode = ctx.attr.unused_dependency_checker_mode,
    )
    return [toolchain]

scala_toolchain = rule(
    _scala_toolchain_impl,
    attrs = {
        "scalacopts": attr.string_list(),
        "scalac_provider_attr": attr.label(
            default = "@io_bazel_rules_scala//scala:scalac_default",
            providers = [_ScalacProvider],
        ),
        "unused_dependency_checker_mode": attr.string(
            default = "off",
            values = ["off", "warn", "error"],
        ),
    },
)
