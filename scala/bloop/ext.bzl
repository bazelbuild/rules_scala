load(
    "//scala:advanced_usage/providers.bzl",
    _ScalaRulePhase = "ScalaRulePhase",
)
load(
    "//scala/private:phases/phases.bzl",
    _phase_bloop = "phase_bloop",
)

ext_add_phase_bloop = {
    "attrs": {
        "_bloop": attr.label(
            cfg = "host",
            default = "//scala/bloop",
            executable = True,
        ),
    },
    "phase_providers": [
        "//scala/bloop:add_phase_bloop",
    ],
}

def _add_phase_bloop_singleton_implementation(ctx):
    return [
        _ScalaRulePhase(
            custom_phases = [
                ("=", "compile", "compile", _phase_bloop),
            ],
        ),
    ]

add_phase_bloop_singleton = rule(
    implementation = _add_phase_bloop_singleton_implementation,
)
