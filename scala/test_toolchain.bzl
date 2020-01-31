TestInfo = provider(
    doc = "TestInfo",
    fields = [
        "jar",
        "reporter",
        "runner",
        "scala_test_jvm_flags",
    ],
)

def _test_toolchain_impl(ctx):
    testinfo = TestInfo(
        jar = ctx.attr.jar,
        reporter = ctx.attr.reporter,
        runner = ctx.attr.runner,
        scala_test_jvm_flags = ctx.attr.scala_test_jvm_flags,
    )
    toolchain = platform_common.ToolchainInfo(
        testinfo = testinfo,
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
