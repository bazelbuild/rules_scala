"""
A phase provider for customizable rules
It is used only when you intend to add functionalities to existing default rules
"""

ScalaRulePhase = provider(
    doc = "A custom phase plugin",
    fields = {
        "custom_phases": "The phases to add. It takes an array of (relation, peer_name, phase_name, phase_function). Please refer to docs/customizable_phase.md for more details.",
    },
)
