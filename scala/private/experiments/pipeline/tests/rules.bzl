load("@io_bazel_rules_scala//scala/private/experiments/pipeline:pickler.bzl", "ScalaSigJar")
load("@bazel_tools//tools/build_rules:test_rules.bzl", "analysis_results")

def _sig_provider_test(ctx):
    return analysis_results(
        ctx,
        result = [
            f.basename
            for f in ctx.attr.target[ScalaSigJar].transitive.to_list()
        ],
        expect = ctx.attr.provides,
    )

sig_provider_test = rule(
    implementation = _sig_provider_test,
    attrs = {
        "target": attr.label(mandatory = True, providers = [ScalaSigJar]),
        "provides": attr.string_list(),
    },
    test = True,
)
