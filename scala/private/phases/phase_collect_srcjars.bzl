#
# PHASE: collect srcjars
#
# DOCUMENT THIS
#

def phase_collect_srcjars(ctx, p):
    # This will be used to pick up srcjars from non-scala library
    # targets (like thrift code generation)
    return _collect_srcjars(ctx.attr.deps)

def _collect_srcjars(targets):
    srcjars = []
    for target in targets:
        if hasattr(target, "srcjars"):
            srcjars.append(target.srcjars.srcjar)
    return depset(srcjars)
