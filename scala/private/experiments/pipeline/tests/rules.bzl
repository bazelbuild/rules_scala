load("@io_bazel_rules_scala//scala/private/experiments/pipeline:pickler.bzl", "ScalaSigJar")
load("@bazel_tools//tools/build_rules:test_rules.bzl", "analysis_results")

def _sig_provider_test(ctx):
    sig = ctx.attr.target[ScalaSigJar]
    return analysis_results(
        ctx,
        result = {
            "direct": sig.direct.basename,
            "plus_one": [f.basename for f in sig.plus_one.to_list()],
            "transitive": [f.basename for f in sig.transitive.to_list()],
        },
        expect = {
            "direct": ctx.attr.direct,
            "plus_one": ctx.attr.plus_one,
            "transitive": ctx.attr.transitive,
        },
    )

sig_provider_test = rule(
    implementation = _sig_provider_test,
    attrs = {
        "target": attr.label(mandatory = True, providers = [ScalaSigJar]),
        "direct": attr.string(),
        "plus_one": attr.string_list(),
        "transitive": attr.string_list(),
    },
    test = True,
)
