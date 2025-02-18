load("@bazel_skylib//lib:unittest.bzl", "analysistest", "asserts")

def _default_outputs_test(ctx):
    env = analysistest.begin(ctx)

    target_under_test = analysistest.target_under_test(env)
    actual_outs = [f.basename for f in target_under_test[DefaultInfo].files.to_list()]

    asserts.equals(env, sorted(ctx.attr.expected_outs), sorted(actual_outs))

    return analysistest.end(env)

default_outputs_test = analysistest.make(
    _default_outputs_test,
    attrs = {
        "expected_outs": attr.string_list(),
    },
)
