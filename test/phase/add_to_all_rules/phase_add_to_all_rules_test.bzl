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
    _make_scala_junit_test = "make_scala_junit_test",
    _make_scala_library = "make_scala_library",
    _make_scala_library_for_plugin_bootstrapping = "make_scala_library_for_plugin_bootstrapping",
    _make_scala_macro_library = "make_scala_macro_library",
    _make_scala_repl = "make_scala_repl",
    _make_scala_test = "make_scala_test",
)
load(
    "//test/phase/add_to_all_rules:phase_add_to_all_rules.bzl",
    _phase_add_to_all_rules = "phase_add_to_all_rules",
)

# Inputs for the customizable rules
ext_add_to_all_rules = {
    "attrs": {
        "custom_content": attr.string(
            default = "This is custom content",
        ),
    },
    "outputs": {
        "custom_output": "%{name}.custom-output",
    },
    "phase_providers": [
        "//test/phase/add_to_all_rules:phase_add_to_all_rules",
    ],
}

# The rule implementation for phase provider
def _add_to_all_rules_singleton_implementation(ctx):
    return [
        _ScalaRulePhase(
            custom_phases = [
                ("last", "", "add_to_all_rules", _phase_add_to_all_rules),
            ],
        ),
    ]

# The rule for phase provider
add_to_all_rules_singleton = rule(
    implementation = _add_to_all_rules_singleton_implementation,
)

add_to_all_rules_scala_binary = _make_scala_binary(ext_add_to_all_rules)
add_to_all_rules_scala_library = _make_scala_library(ext_add_to_all_rules)
add_to_all_rules_scala_library_for_plugin_bootstrapping = _make_scala_library_for_plugin_bootstrapping(ext_add_to_all_rules)
add_to_all_rules_scala_macro_library = _make_scala_macro_library(ext_add_to_all_rules)
add_to_all_rules_scala_test = _make_scala_test(ext_add_to_all_rules)
add_to_all_rules_scala_junit_test = _make_scala_junit_test(ext_add_to_all_rules)
add_to_all_rules_scala_repl = _make_scala_repl(ext_add_to_all_rules)
