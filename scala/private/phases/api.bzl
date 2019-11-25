load(
    "@io_bazel_rules_scala//scala:advanced_usage/providers.bzl",
    _ScalaRulePhase = "ScalaRulePhase",
)

def _adjust_phases(phases, adjustments):
    if len(adjustments) == 0:
        return phases
    phases = phases[:]
    for (relation, peer_name, name, function) in adjustments:
        for idx, (needle, _) in enumerate(phases):
            if relation in ["^", "first"]:
                phases.insert(0, (name, function))
            elif relation in ["$", "last"]:
                phases.append((name, function))
            elif needle == peer_name:
                if relation in ["-", "before"]:
                    phases.insert(idx, (name, function))
                elif relation in ["+", "after"]:
                    phases.insert(idx + 1, (name, function))
                elif relation in ["=", "replace"]:
                    phases[idx] = (name, function)
    return phases

def run_phases(ctx, builtin_customizable_phases, fixed_phase):
    phase_providers = [
        phase_provider[_ScalaRulePhase]
        for phase_provider in ctx.attr._phase_providers
        if _ScalaRulePhase in phase_provider
    ]

    adjusted_phases = _adjust_phases(
        builtin_customizable_phases,
        [
            phase
            for phase_provider in phase_providers
            for phase in phase_provider.custom_phases
        ],
    )

    global_provider = {}
    current_provider = struct(**global_provider)
    for (name, function) in adjusted_phases + [fixed_phase]:
        new_provider = function(ctx, current_provider)
        if new_provider != None:
            global_provider[name] = new_provider
            current_provider = struct(**global_provider)

    return current_provider

def extras_phases(extras):
    return {
        "_phase_providers": attr.label_list(
            default = [
                phase_provider
                for extra in extras
                for phase_provider in extra["phase_providers"]
            ],
            providers = [_ScalaRulePhase],
        ),
    }
