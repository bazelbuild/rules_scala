TestInfo = provider(
    doc = "TestInfo",
    fields = [
    ],
)

def _test_toolchain_impl(ctx):
    toolchain = platform_common.ToolchainInfo(
    )
    return [toolchain]

test_toolchain = rule(
    _test_toolchain_impl,
    attrs = {
    },
)
