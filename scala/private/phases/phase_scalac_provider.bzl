#
# PHASE: scalac provider
#
# DOCUMENT THIS
#

def phase_scalac_provider(ctx, p):
    return ctx.toolchains["@io_bazel_rules_scala//scala:bootstrap_toolchain_type"]
