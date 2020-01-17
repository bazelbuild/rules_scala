"""
This test makes sure custom phases can be inserted to the desired position through phase API
"""

load(
    "//scala:advanced_usage/providers.bzl",
    _ScalaRulePhase = "ScalaRulePhase",
)
load(
    "//scala:advanced_usage/scala.bzl",
    _make_scala_library = "make_scala_library",
)
load(
    "//test/phase/adjustment:phase_adjustment.bzl",
    _phase_being_replaced = "phase_being_replaced",
    _phase_check_replacement = "phase_check_replacement",
    _phase_first = "phase_first",
    _phase_replace = "phase_replace",
    _phase_second = "phase_second",
    _phase_third = "phase_third",
)

# Inputs for the customizable rules
ext_adjustment = {
    "outputs": {
        "custom_output": "%{name}.custom-output",
    },
    "phase_providers": [
        "//test/phase/adjustment:phase_adjustment",
    ],
}

# The rule implementation for phase provider
def _adjustment_singleton_implementation(ctx):
    return [
        _ScalaRulePhase(
            custom_phases = [
                ("last", "", "second", _phase_second),
                ("before", "second", "first", _phase_first),
                ("after", "second", "third", _phase_third),
            ],
        ),
    ]

# The rule for phase provider
adjustment_singleton = rule(
    implementation = _adjustment_singleton_implementation,
)

adjustment_scala_library = _make_scala_library(ext_adjustment)

# Inputs for the customizable rules
ext_adjustment_replace = {
    "outputs": {
        "custom_output": "%{name}.custom-output",
    },
    "phase_providers": [
        "//test/phase/adjustment:phase_adjustment_replace",
    ],
}

# The rule implementation for phase provider
def _adjustment_replace_singleton_implementation(ctx):
    return [
        _ScalaRulePhase(
            custom_phases = [
                ("last", "", "check_replacement", _phase_check_replacement),
                ("before", "check_replacement", "being_replaced", _phase_being_replaced),
                ("replace", "being_replaced", "replace", _phase_replace),
            ],
        ),
    ]

# The rule for phase provider
adjustment_replace_singleton = rule(
    implementation = _adjustment_replace_singleton_implementation,
)

adjustment_replace_scala_library = _make_scala_library(ext_adjustment_replace)
