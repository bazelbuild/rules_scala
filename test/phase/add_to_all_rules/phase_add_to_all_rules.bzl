#
# PHASE: add to all rules
#
# A dummy test phase to make sure phase is working for all rules
#
def phase_add_to_all_rules(ctx, p):
    ctx.actions.write(
        output = ctx.outputs.custom_output,
        content = ctx.attr.custom_content,
    )
