def _scala_toolchain_impl(ctx):
  toolchain = platform_common.ToolchainInfo(
    scalacopts = ctx.attr.scalacopts,
  )
  return [toolchain]

scala_toolchain = rule(
  _scala_toolchain_impl,
  attrs = {
    'scalacopts': attr.string_list(),
  }
)