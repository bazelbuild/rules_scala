DepsInfo = provider(
    doc = "Defines depset required by rules",
    fields = {
        "deps": "Deps",
        "deps_id": "Identifier by which rules access this depset",
    },
)

def _declare_deps_provider(ctx):
    return [
        DepsInfo(
            deps = ctx.attr.deps,
            deps_id = ctx.attr.deps_id,
        ),
    ]

declare_deps_provider = rule(
    implementation = _declare_deps_provider,
    attrs = {
        "deps": attr.label_list(allow_files = True),
        "deps_id": attr.string(mandatory = True),
    },
)

ScalacProvider = provider(
    doc = "ScalacProvider",
    fields = [
        "default_classpath",
        "default_macro_classpath",
        "default_repl_classpath",
    ],
)

ScalaInfo = provider(
    doc = "Contains information about Scala targets.",
    fields = {
        "contains_macros": "Whether this target contains macros.",
    },
)
