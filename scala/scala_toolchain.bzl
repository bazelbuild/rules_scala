def _scala_toolchain_impl(ctx):
  toolchain = platform_common.ToolchainInfo(
      scalacopts = ctx.attr.scalacopts,
      unused_dependency_checker_mode = ctx.attr.unused_dependency_checker_mode)
  return [toolchain]

scala_toolchain = rule(
    _scala_toolchain_impl,
    attrs = {
        'scalacopts': attr.string_list(),
        'unused_dependency_checker_mode': attr.string(
            default = "off", values = ["off", "warn", "error"]),
    })
