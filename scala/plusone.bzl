PlusOneDeps = provider(
    fields = {
        'direct_deps' : 'list of direct compile dependencies of a target',
    }
)

def _collect_plus_one_deps_aspect_impl(target, ctx):
    return [PlusOneDeps(direct_deps = getattr(ctx.rule.attr,'deps',[]))]

collect_plus_one_deps_aspect = aspect(implementation = _collect_plus_one_deps_aspect_impl,
    attr_aspects = ['deps'],
)
