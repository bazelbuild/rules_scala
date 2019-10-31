#
# PHASE: collect srcjars
#
# DOCUMENT THIS
#
load(
    "@io_bazel_rules_scala//scala/private:common.bzl",
    "collect_srcjars",
)

def phase_collect_srcjars(ctx, p):
    # This will be used to pick up srcjars from non-scala library
    # targets (like thrift code generation)
    return collect_srcjars(ctx.attr.deps)
