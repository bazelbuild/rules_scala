def phase_scalacopts(ctx, p):
    toolchain = ctx.toolchains["@io_bazel_rules_scala//scala:toolchain_type"]
    return toolchain.scalacopts + ctx.attr.scalacopts
