ScalacProvider = provider(
    doc = "ScalacProvider",
    fields = [
        "default_classpath",
        "default_macro_classpath",
        "default_repl_classpath",
    ],
)

def _declare_scalac_provider(ctx):
    return [
        ScalacProvider(
            default_classpath = ctx.attr.default_classpath,
            default_repl_classpath = ctx.attr.default_repl_classpath,
            default_macro_classpath = ctx.attr.default_macro_classpath,
        ),
    ]

declare_scalac_provider = rule(
    implementation = _declare_scalac_provider,
    attrs = {
        "default_classpath": attr.label_list(allow_files = True),
        "default_repl_classpath": attr.label_list(allow_files = True),
        "default_macro_classpath": attr.label_list(allow_files = True),
    },
)
