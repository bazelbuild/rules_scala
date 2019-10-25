load(
    "@io_bazel_rules_scala//scala:providers.bzl",
    _ScalaRulePhase = "ScalaRulePhase",
)

def _adjust_phases(phases, adjustments):
    if len(adjustments) == 0:
        return phases
    phases = phases[:]
    for (relation, peer_name, name, function) in adjustments:
        for idx, (needle, _) in enumerate(phases):
            if needle == peer_name:
                if relation in ["-", "before"]:
                    phases.insert(idx, (name, function))
                elif relation in ["+", "after"]:
                    phases.insert(idx + 1, (name, function))
                elif relation in ["=", "replace"]:
                    phases[idx] = (name, function)
    return phases

def run_phases(ctx, phases):
    phase_providers = [
        p[_ScalaRulePhase]
        for p in ctx.attr._phase_providers
        if _ScalaRulePhase in p
    ]

    if phase_providers != []:
        phases = _adjust_phases(phases, [p for pp in phase_providers for p in pp.phases])

    global_provider = {}
    current_provider = struct(**global_provider)
    for (name, function) in phases:
        new_provider = function(ctx, current_provider)
        if new_provider != None:
            global_provider[name] = new_provider
            current_provider = struct(**global_provider)

    return current_provider

def extras_phases(extras):
    return {
        "_phase_providers": attr.label_list(
            default = [pp for extra in extras for pp in extra["phase_providers"]],
            providers = [_ScalaRulePhase],
        ),
    }
