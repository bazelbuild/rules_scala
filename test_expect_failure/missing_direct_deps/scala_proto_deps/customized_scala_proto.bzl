load("//scala_proto:scala_proto.bzl", "make_scala_proto_aspect", "make_scala_proto_library")
load("@io_bazel_rules_scala//scala:advanced_usage/providers.bzl", "ScalaRulePhase")

def _phase_custom_stamping_convention(ctx, p):
    rule_label = str(p.target.label)
    toolchain = ctx.toolchains["@io_bazel_rules_scala//scala_proto:toolchain_type"]

    if toolchain.stamp_by_convention:
        return rule_label + "_custom_suffix"
    else:
        return rule_label

def _custom_stamping_convention_implementation(ctx):
    return [
        ScalaRulePhase(
            custom_phases = [
                ("=", "stamp_label", "stamp_label", _phase_custom_stamping_convention),
            ],
        ),
    ]

custom_stamping_convention = rule(
    implementation = _custom_stamping_convention_implementation,
)

_custom_phases = {
    "phase_providers": [
        "//test_expect_failure/missing_direct_deps/scala_proto_deps:phase_custom_stamping",
    ],
}

custom_stamping_apsect = make_scala_proto_aspect(_custom_phases)

custom_stamping_scala_proto_library = make_scala_proto_library(aspects = [custom_stamping_apsect])
