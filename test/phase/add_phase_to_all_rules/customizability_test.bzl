"""
This test makes sure custom phases can be inserted to the desired position through phase API
"""

load(
    "//scala:advanced_usage/providers.bzl",
    _ScalaRulePhase = "ScalaRulePhase",
)
load(
    "//scala:advanced_usage/scala.bzl",
    _make_scala_binary = "make_scala_binary",
    _make_scala_library = "make_scala_library",
    _make_scala_library_for_plugin_bootstrapping = "make_scala_library_for_plugin_bootstrapping",
    _make_scala_macro_library = "make_scala_macro_library",
    _make_scala_test = "make_scala_test",
    _make_scala_junit_test = "make_scala_junit_test",
    _make_scala_repl = "make_scala_repl",
)
load(
    "//test/phase/add_phase_to_all_rules:phase_customizability_test.bzl",
    _phase_customizability_test = "phase_customizability_test",
)

# Inputs for the customizable rules
ext_add_phase_customizability_test = {
    "attrs": {
        "custom_content": attr.string(
            default = "This is custom content",
        ),
    },
    "outputs": {
        "custom_output": "%{name}.custom-output",
    },
    "phase_providers": [
        "//test/phase/add_phase_to_all_rules:phase_customizability_test",
    ],
}

# The rule implementation for phase provider
def _add_phase_customizability_test_singleton_implementation(ctx):
    return [
        _ScalaRulePhase(
            custom_phases = [
                ("$", "", "customizability_test", _phase_customizability_test),
            ],
        ),
    ]

# The rule for phase provider
add_phase_customizability_test_singleton = rule(
    implementation = _add_phase_customizability_test_singleton_implementation,
)

customizability_test_scala_binary = _make_scala_binary(ext_add_phase_customizability_test)
customizability_test_scala_library = _make_scala_library(ext_add_phase_customizability_test)
customizability_test_scala_library_for_plugin_bootstrapping = _make_scala_library_for_plugin_bootstrapping(ext_add_phase_customizability_test)
customizability_test_scala_macro_library = _make_scala_macro_library(ext_add_phase_customizability_test)
customizability_test_scala_test = _make_scala_test(ext_add_phase_customizability_test)
customizability_test_scala_junit_test = _make_scala_junit_test(ext_add_phase_customizability_test)
customizability_test_scala_repl = _make_scala_repl(ext_add_phase_customizability_test)
