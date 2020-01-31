BootstrapInfo = provider(
    doc = "BootstrapInfo",
    fields = [
        "classpath",
        "macro_classpath",
        "repl_classpath",
    ],
)

def _impl(ctx):
    toolchain = platform_common.ToolchainInfo(
        bootstrapinfo = BootstrapInfo(
            classpath = ctx.attr.classpath,
            macro_classpath = ctx.attr.macro_classpath,
            repl_classpath = ctx.attr.repl_classpath,
        )
    )
    return [toolchain]

bootstrap_toolchain = rule(
    _impl,
    attrs = {
        "classpath": attr.label_list(mandatory = True, allow_files = True),
        "repl_classpath": attr.label_list(mandatory = True, allow_files = True),
        "macro_classpath": attr.label_list(mandatory = True, allow_files = True),
    },
)
