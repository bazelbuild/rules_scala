"""
The phase API for rules implementation
"""

load(
    "//scala:advanced_usage/providers.bzl",
    _ScalaRulePhase = "ScalaRulePhase",
)
load("@bazel_skylib//lib:dicts.bzl", "dicts")

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
    # phase_name: the name of the new phase, also used to access phase information
    # phase_function: the function of the new phase
    for (relation, peer_name, phase_name, phase_function) in adjustments:
        if relation in ["^", "first"]:
            phases.insert(0, (phase_name, phase_function))
        elif relation in ["$", "last"]:
            phases.append((phase_name, phase_function))
        else:
            for idx, (needle, _) in enumerate(phases):
                if needle == peer_name:
                    if relation in ["-", "before"]:
                        phases.insert(idx, (phase_name, phase_function))
                        break
                    elif relation in ["+", "after"]:
                        phases.insert(idx + 1, (phase_name, phase_function))
                        break
                    elif relation in ["=", "replace"]:
                        phases[idx] = (phase_name, phase_function)
                        break
    return phases

def run_phases(ctx, builtin_customizable_phases):
    return _run_phases(ctx, builtin_customizable_phases, target = None)

def run_aspect_phases(ctx, builtin_customizable_phases, target):
    return _run_phases(ctx, builtin_customizable_phases, target)

def _run_phases(ctx, builtin_customizable_phases, target):
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
    global_provider = {
        "target": target,
    }
    current_provider = struct(**global_provider)
    acculmulated_external_providers = {}
    for (name, function) in adjusted_phases:
        # Run a phase
        new_provider = function(ctx, current_provider)

        # If a phase returns data, append it to global_provider
        # for later phases to access
        if new_provider != None:
            if (hasattr(new_provider, "external_providers")):
                acculmulated_external_providers = dicts.add(
                    acculmulated_external_providers,
                    new_provider.external_providers,
                )
            global_provider[name] = new_provider
            current_provider = struct(**global_provider)

    # The final return of rules implementation
    return acculmulated_external_providers.values()

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
