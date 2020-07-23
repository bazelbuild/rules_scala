ScalacProvider = provider(
    doc = "ScalacProvider",
    fields = [
        "default_classpath",
        "default_macro_classpath",
        "default_repl_classpath",
    ],
)

DepsInfo = provider(
    doc = "Dependencies needed for specifc rules",
    fields = [
        "deps",
    ],
)

def _declare_deps_provider(ctx):
    return [
        DepsInfo(
            deps = ctx.attr.deps,
        ),
    ]

declare_deps_provider = rule(
    implementation = _declare_deps_provider,
    attrs = {
        "deps": attr.label_list(allow_files = True),
    },
)
