load("@bazel_skylib//lib:new_sets.bzl", "sets")
load("@bazel_skylib//lib:unittest.bzl", "analysistest", "asserts")
load("@rules_java//java/common:java_info.bzl", "JavaInfo")

# Tests and documents the functionality of phase_compile.bzl's _pack_source_jar

def _source_jar_test_impl(ctx):
    env = analysistest.begin(ctx)

    target_under_test = analysistest.target_under_test(env)

    srcjar_names = sets.make(
        [j.basename for j in target_under_test[JavaInfo].source_jars],
    )

    expected_names = sets.make(ctx.attr.expected_basenames)

    asserts.set_equals(env, expected = expected_names, actual = srcjar_names)

    return analysistest.end(env)

def _make_source_jar_test():
    return analysistest.make(
        impl = _source_jar_test_impl,
        attrs = {
            "expected_basenames": attr.string_list(
                mandatory = True,
                allow_empty = True,
            ),
        },
    )

source_jar_test = _make_source_jar_test()

def pack_sources_test_suite(name):
    source_jar_test(
        name = "single_source_jar_test",
        target_under_test = ":source_jar",

        # In line with Bazel's java_common.pack_sources,
        # We return the initial .srcjar file since there are no source files
        # Not sure where the second -src.jar comes from, maybe due to java rules
        # It can be removed by adding the target attr expect_java_output = False
        expected_basenames = [
            "SourceJar1.srcjar",
            "source_jar_java-src.jar",
        ],
    )
    source_jar_test(
        name = "single_source_jar_no_java_output_test",
        target_under_test = ":source_jar_no_expect_java_output",
        expected_basenames = [
            "SourceJar1.srcjar",
        ],
    )
    source_jar_test(
        name = "multi_source_jar_test",
        target_under_test = ":multi_source_jar",
        expected_basenames = [
            "multi_source_jar-src.jar",
            "multi_source_jar_java-src.jar",
        ],
    )
    source_jar_test(
        name = "mixed_source_jar_test",
        target_under_test = ":mixed_source_jar",
        expected_basenames = [
            "mixed_source_jar-src.jar",
            "mixed_source_jar_java-src.jar",
        ],
    )
    source_jar_test(
        name = "source_jar_with_srcs_test",
        target_under_test = ":use_source_jar",
        expected_basenames = [
            "use_source_jar-src.jar",
        ],
    )

    native.test_suite(
        name = name,
        tests = [
            ":single_source_jar_test",
            ":single_source_jar_no_java_output_test",
            ":multi_source_jar_test",
            ":mixed_source_jar_test",
            ":source_jar_with_srcs_test",
        ],
    )
