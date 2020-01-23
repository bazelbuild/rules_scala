load("@io_bazel_rules_scala//scala:advanced_usage/providers.bzl", "ScalaRulePhase")
load("@io_bazel_rules_scala//scala:advanced_usage/scala.bzl", "make_scala_library")

ext_phase_override_provider = {
    "phase_providers": [
        "//test/phase/providers:phase_override_provider_singleton_target",
    ],
}

rule_that_has_phases_which_override_providers = make_scala_library(ext_phase_override_provider)

def _phase_override_provider_singleton_implementation(ctx):
    return [
        ScalaRulePhase(
            custom_phases = [
                ("last", "", "first_custom", _phase_original),
                ("after", "first_custom", "second_custom", _phase_override),
            ],
        ),
    ]

phase_override_provider_singleton = rule(
    implementation = _phase_override_provider_singleton_implementation,
)

OverrideProvider = provider(fields = ["content"])

def _phase_original(ctx, p):
    return struct(
        external_providers = {
            "OverrideProvider": OverrideProvider(
                content = "original",
            ),
        },
    )

def _phase_override(ctx, p):
    return struct(
        external_providers = {
            "OverrideProvider": OverrideProvider(
                content = "override",
            ),
        },
    )

def _rule_that_verifies_providers_are_overriden_impl(ctx):
    if (ctx.attr.dep[OverrideProvider].content != "override"):
        fail(
            "expected OverrideProvider of {label} to have content 'override' but got '{content}'".format(
                label = ctx.label,
                content = ctx.attr.dep[OverrideProvider].content,
            ),
        )
    return []

rule_that_verifies_providers_are_overriden = rule(
    implementation = _rule_that_verifies_providers_are_overriden_impl,
    attrs = {
        "dep": attr.label(providers = [OverrideProvider]),
    },
)
