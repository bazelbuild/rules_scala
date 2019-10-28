load(
    "//scala:providers.bzl",
    _ScalaRulePhase = "ScalaRulePhase",
)
load(
    "//scala/private:phases/phases.bzl",
    _phase_scalafmt = "phase_scalafmt",
)

ext_add_phase_scalafmt = {
    "attrs": {
        "config": attr.label(
            allow_single_file = [".conf"],
            default = "@scalafmt_default//:config",
            doc = "The Scalafmt configuration file.",
        ),
        "_fmt": attr.label(
            cfg = "host",
            default = "//scala/scalafmt",
            executable = True,
        ),
        "_runner": attr.label(
            allow_single_file = True,
            default = "//scala/scalafmt:runner",
        ),
        "_testrunner": attr.label(
            allow_single_file = True,
            default = "//scala/scalafmt:testrunner",
        ),
        "format": attr.bool(
            default = False,
        ),
    },
    "outputs": {
        "scalafmt_runner": "%{name}.format",
        "scalafmt_testrunner": "%{name}.format-test",
    },
    "phase_providers": [
        "//scala/scalafmt:add_phase_scalafmt",
    ],
}

def _add_phase_scalafmt_singleton_implementation(ctx):
    return [
        _ScalaRulePhase(
            phases = [
                ("$", "", "scalafmt", _phase_scalafmt),
            ],
        ),
    ]

add_phase_scalafmt_singleton = rule(
    implementation = _add_phase_scalafmt_singleton_implementation,
)
