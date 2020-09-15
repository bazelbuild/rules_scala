load("@io_bazel_rules_scala//scala:providers.bzl", "DepsInfo")
load(
    "@io_bazel_rules_scala//scala/private/toolchain_deps:toolchain_deps.bzl",
    "expose_toolchain_deps",
)

def _scrooge_toolchain_impl(ctx):
    toolchain = platform_common.ToolchainInfo(
        dep_providers = ctx.attr.dep_providers,
    )
    return [toolchain]

scrooge_toolchain = rule(
    _scrooge_toolchain_impl,
    attrs = {
        "dep_providers": attr.label_list(
            default = [
                "@io_bazel_rules_scala//twitter_scrooge:compile_classpath_provider",
                "@io_bazel_rules_scala//twitter_scrooge:aspect_compile_classpath_provider",
                "@io_bazel_rules_scala//twitter_scrooge:compiler_classpath_provider",
                "@io_bazel_rules_scala//twitter_scrooge:scrooge_generator_provider",
            ],
            providers = [DepsInfo],
        ),
    },
)

def _export_scrooge_deps_impl(ctx):
    return expose_toolchain_deps(
        ctx,
        "@io_bazel_rules_scala//twitter_scrooge/toolchain:scrooge_toolchain_type",
    )

export_scrooge_deps = rule(
    _export_scrooge_deps_impl,
    attrs = {
        "deps_id": attr.string(
            mandatory = True,
        ),
    },
    toolchains = ["@io_bazel_rules_scala//twitter_scrooge/toolchain:scrooge_toolchain_type"],
)
