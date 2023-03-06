#
# PHASE: phase semanticdb
#
# Outputs for semanticdb when enabled in toolchain 
#
def phase_semanticdb(ctx, p):
    toolchain = ctx.toolchains["@io_bazel_rules_scala//scala:toolchain_type"]
    enable_semanticdb = toolchain.enable_semanticdb

    if enable_semanticdb:
        return struct(enabled = True)
    else:
        return struct(enabled = False)
