ScalaTestInfo = provider(
    doc = "ScalaTestInfo",
    fields = [
        "deps",
        "reporter",
        "runner",
        "scala_test_jvm_flags",
    ],
)

def _scala_test_toolchain_impl(ctx):
    scalatestinfo = ScalaTestInfo(
        deps = ctx.attr.deps,
        reporter = ctx.attr.reporter,
        runner = ctx.attr.runner,
        scala_test_jvm_flags = ctx.attr.scala_test_jvm_flags,
    )
    toolchain = platform_common.ToolchainInfo(
        scalatestinfo = scalatestinfo,
    )
    return [toolchain, platform_common.TemplateVariableInfo()]

scala_test_toolchain = rule(
    _scala_test_toolchain_impl,
    attrs = {
        "deps": attr.label_list(
            providers = [JavaInfo],
            mandatory = True,
        ),
        "reporter": attr.label(mandatory = True),
        "runner": attr.label(mandatory = True),
        "scala_test_jvm_flags": attr.string_list(),
    },
)
