def phase_scalacopts(ctx, p):
    toolchain = ctx.toolchains[Label("//scala:toolchain_type")]
    return toolchain.scalacopts + ctx.attr.scalacopts
