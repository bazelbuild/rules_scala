#
# PHASE: adjustment test
#
# Dummy test phases to make sure phase adjustment is working
#
def phase_first(ctx, p):
    return struct(
        info_first = "info from phase_first",
    )

def phase_second(ctx, p):
    return struct(
        info_first = "phase_second redirect " + p.first.info_first,
        info_second = "info from phase_second",
    )

def phase_third(ctx, p):
    ctx.actions.write(
        output = ctx.outputs.custom_output,
        content = "{} {} {}".format(p.first.info_first, p.second.info_first, p.second.info_second),
    )

def phase_replace(ctx, p):
    return struct(
        info = "expected info from phase_replace",
    )

def phase_being_replaced(ctx, p):
    return struct(
        info = "unexpected info from phase_being_replaced",
    )

def phase_check_replacement(ctx, p):
    final_info = ""
    if getattr(p, "replace"):
        final_info += p.replace.info
    if hasattr(p, "being_replaced"):
        final_info += p.being_replaced.info
    ctx.actions.write(
        output = ctx.outputs.custom_output,
        content = "{} we should only see one info".format(final_info),
    )
