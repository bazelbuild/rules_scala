#
# PHASE: collect srcjars
#
# DOCUMENT THIS
#

def phase_collect_srcjars(ctx, p):
    # This will be used to pick up srcjars from non-scala library
    # targets (like thrift code generation)
    srcjars = []
    for target in ctx.attr.deps:
        if hasattr(target, "srcjars"):
            srcjars.append(target.srcjars.srcjar)
    return depset(srcjars)
