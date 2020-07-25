ScalacProvider = provider(
    doc = "ScalacProvider",
    fields = [
        "default_classpath",
        "default_macro_classpath",
        "default_repl_classpath",
    ],
)

DepsInfo = provider(
    doc = "Defines depset required by rules",
    fields = {
        "deps": "Depset",
        "depset_id": "Identifier by which rules access this depset",
    },
)

def _declare_deps_provider(ctx):
    return [
        DepsInfo(
            deps = ctx.attr.deps,
            depset_id = ctx.attr.depset_id,
        ),
    ]

declare_deps_provider = rule(
    implementation = _declare_deps_provider,
    attrs = {
        "deps": attr.label_list(allow_files = True),
        "depset_id": attr.string(mandatory = True),
    },
)
