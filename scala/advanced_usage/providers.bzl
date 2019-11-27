"""
A phase provider for customizable rules
It is used only when you intend to add functionalities to existing default rules
"""

ScalaRulePhase = provider(
    doc = "A custom phase plugin",
    fields = {
        "custom_phases": "the phases to add",
    },
)
