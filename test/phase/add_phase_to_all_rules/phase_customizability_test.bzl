#
# PHASE: customizability test
#
# A dummy test phase to make sure rules are customizable
#
def phase_customizability_test(ctx, p):
    ctx.actions.write(
        output = ctx.outputs.custom_output,
        content = ctx.attr.custom_content,
    )
