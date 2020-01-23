load("@io_bazel_rules_scala//scala:advanced_usage/providers.bzl", "ScalaRulePhase")
load("@io_bazel_rules_scala//scala:advanced_usage/scala.bzl", "make_scala_library")

ext_phase_expose_provider = {
    "phase_providers": [
        "//test/phase/providers:phase_expose_provider_singleton_target",
    ],
}

scala_library_that_exposes_custom_provider = make_scala_library(ext_phase_expose_provider)

_some_position = "last"  #last position is just because a location is mandatory, not important

def _phase_expose_provider_singleton_implementation(ctx):
    return [
        ScalaRulePhase(
            custom_phases = [
                (_some_position, "", "phase_expose_provider", _phase_expose_provider),
            ],
        ),
    ]

phase_expose_provider_singleton = rule(
    implementation = _phase_expose_provider_singleton_implementation,
)

CustomProviderExposedByPhase = provider()

def _phase_expose_provider(ctx, p):
    return struct(
        external_providers = {"CustomProviderExposedByPhase": CustomProviderExposedByPhase()},
    )

def _rule_that_needs_custom_provider_impl(ctx):
    return []

rule_that_needs_custom_provider = rule(
    implementation = _rule_that_needs_custom_provider_impl,
    attrs = {
        "dep": attr.label(providers = [CustomProviderExposedByPhase]),
    },
)
