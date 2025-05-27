load("@bazel_skylib//lib:collections.bzl", "collections")
load("@bazel_skylib//lib:unittest.bzl", "analysistest", "asserts", "unittest")
load("@rules_java//java/common:java_info.bzl", "JavaInfo")
load("@rules_scala//scala:advanced_usage/scala.bzl", "make_scala_test")
load("@rules_scala//scala/scalafmt:phase_scalafmt_ext.bzl", "ext_scalafmt")

# From //test/scalafmt:phase_scalafmt_test.bzl
scalafmt_scala_test = make_scala_test(ext_scalafmt)

# From //test/proto:default_outputs_test.bzl
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

# From
# //test/src/main/scala/scalarules/test/twitter_scrooge:twitter_scrooge_test.bzl
def _scrooge_transitive_outputs(ctx):
    env = unittest.begin(ctx)

    asserts.equals(
        env,
        sorted(ctx.attr.expected_jars),
        sorted(collections.uniq([out.class_jar.basename for out in ctx.attr.dep[JavaInfo].outputs.jars])),
    )

    return unittest.end(env)

scrooge_transitive_outputs_test = unittest.make(
    _scrooge_transitive_outputs,
    attrs = {
        "dep": attr.label(),
        "expected_jars": attr.string_list(),
    },
)
