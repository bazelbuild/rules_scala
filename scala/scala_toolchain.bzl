def _scala_toolchain_impl(ctx):
  toolchain = platform_common.ToolchainInfo(
    scalacopts = ctx.attr.scalacopts,
    worker = ctx.executable.worker,
    library = ctx.attr.library,
    compiler = ctx.attr.compiler,
    reflect = ctx.attr.reflect,
  )
  return [toolchain]

scala_toolchain = rule(
  _scala_toolchain_impl,
  attrs = {
    'scalacopts': attr.string_list(),
    'worker': attr.label(executable=True, cfg="host", allow_files=True),
    'library': attr.label(allow_files=True),
    'compiler': attr.label(allow_files=True),
    'reflect': attr.label(allow_files=True),
  }
)
