load("@bazel_skylib//lib:unittest.bzl", "analysistest", "asserts")

def _assert_exposes_srcjar(ctx):
    env = analysistest.begin(ctx)
    target_under_test = analysistest.target_under_test(env)
    expected_source_jar = ctx.file.source_jar

    asserts.true(
        env,
        OutputGroupInfo in target_under_test,
        msg = "provider 'OutputGroupinfo' is not provided by target_under_test.",
    )

    output_group_info = target_under_test[OutputGroupInfo]
    asserts.true(
        env,
        "_source_jars" in output_group_info,
        msg = "provider 'OutputGroupInfo' doesn't contain '_source_jars' info.",
    )

    actual_source_jars = output_group_info["_source_jars"].to_list()
    asserts.equals(
        env,
        [expected_source_jar],
        actual_source_jars,
    )

    return analysistest.end(env)

exposes_srcjar_test = analysistest.make(
    _assert_exposes_srcjar,
    attrs = {"source_jar": attr.label(allow_single_file = True)},
)
