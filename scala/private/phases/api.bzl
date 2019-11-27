"""
The phase API for rules implementation
"""

load(
    "@io_bazel_rules_scala//scala:advanced_usage/providers.bzl",
    _ScalaRulePhase = "ScalaRulePhase",
)

# A method to modify the built-in phase list
# - Insert new phases to the first/last position
# - Insert new phases before/after existing phases
# - Replace existing phases
def _adjust_phases(phases, adjustments):
    # Return when no adjustment needed
    if len(adjustments) == 0:
        return phases
    phases = phases[:]
    # relation: the position to add a new phase
    # peer_name: the existing phase to compare the position with
    # name: the name of the new phase
    # function: the function of the new phase
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

# Execute phases
def run_phases(ctx, builtin_customizable_phases, fixed_phase):
    # Loading custom phases
    # Phases must be passed in by provider
    phase_providers = [
        phase_provider[_ScalaRulePhase]
        for phase_provider in ctx.attr._phase_providers
        if _ScalaRulePhase in phase_provider
    ]

    # Modify the built-in phase list
    adjusted_phases = _adjust_phases(
        builtin_customizable_phases,
        [
            phase
            for phase_provider in phase_providers
            for phase in phase_provider.custom_phases
        ],
    )

    # A placeholder for data shared with later phases
    global_provider = {}
    current_provider = struct(**global_provider)
    for (name, function) in adjusted_phases + [fixed_phase]:
        # Run a phase
        new_provider = function(ctx, current_provider)
        # If a phase returns data, append it to global_provider
        # for later phases to access
        if new_provider != None:
            global_provider[name] = new_provider
            current_provider = struct(**global_provider)

    # The final return of rules implementation
    return current_provider

# A method to pass in phase provider
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
