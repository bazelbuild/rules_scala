def _test_toolchain_impl(ctx):
    toolchain = platform_common.ToolchainInfo(
        jar = ctx.attr.jar,
        reporter = ctx.attr.reporter,
        runner = ctx.attr.runner,
        scala_test_jvm_flags = ctx.attr.scala_test_jvm_flags,
    )
    return [toolchain]

test_toolchain = rule(
    _test_toolchain_impl,
    attrs = {
        "jar": attr.label(mandatory = True),
        "reporter": attr.label(mandatory = True),
        "runner": attr.label(mandatory = True),
        "scala_test_jvm_flags": attr.string_list(),
    },
)
