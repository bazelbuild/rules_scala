load("@bazel_skylib//lib:unittest.bzl", "analysistest", "asserts")
load("@bazel_skylib//lib:new_sets.bzl", "sets")

# Tests and documents the functionality of phase_compile.bzl's _pack_source_jar

def _single_source_jar_test_impl(ctx):
    env = analysistest.begin(ctx)

    target_under_test = analysistest.target_under_test(env)

    srcjar_names = sets.make(
        [j.basename for j in target_under_test[JavaInfo].source_jars],
    )

    # In line with Bazel's java_common.pack_sources,
    # We return the initial .srcjar file since there are no source files
    # Not sure where the second -src.jar comes from, maybe due to java rules
    expected_names = sets.make([
        "SourceJar1.srcjar",
        "source_jar_java-src.jar",
    ])

    asserts.set_equals(env, expected = expected_names, actual = srcjar_names)

    return analysistest.end(env)

single_source_jar_test = analysistest.make(_single_source_jar_test_impl)

def _multi_source_jar_test_impl(ctx):
    env = analysistest.begin(ctx)

    target_under_test = analysistest.target_under_test(env)

    srcjar_names = sets.make(
        [j.basename for j in target_under_test[JavaInfo].source_jars],
    )

    expected_names = sets.make([
        "multi_source_jar-src.jar",
        "multi_source_jar_java-src.jar",
    ])

    asserts.set_equals(env, expected = expected_names, actual = srcjar_names)

    return analysistest.end(env)

multi_source_jar_test = analysistest.make(_multi_source_jar_test_impl)

def _source_jar_with_srcs_test_impl(ctx):
    env = analysistest.begin(ctx)

    target_under_test = analysistest.target_under_test(env)

    srcjar_names = sets.make(
        [j.basename for j in target_under_test[JavaInfo].source_jars],
    )

    # Since we have source files, we don't output a .srcjar
    # Instead, we just return the bundle
    expected_names = sets.make([
        "use_source_jar-src.jar",
    ])

    asserts.set_equals(env, expected = expected_names, actual = srcjar_names)

    return analysistest.end(env)

source_jar_with_srcs_test = analysistest.make(_source_jar_with_srcs_test_impl)

def pack_sources_test_suite(name):
    single_source_jar_test(
        name = "single_source_jar_test",
        target_under_test = ":source_jar",
    )
    multi_source_jar_test(
        name = "multi_source_jar_test",
        target_under_test = ":multi_source_jar",
    )
    source_jar_with_srcs_test(
        name = "source_jar_with_srcs_test",
        target_under_test = ":use_source_jar",
    )

    native.test_suite(
        name = name,
        tests = [
            ":single_source_jar_test",
            ":multi_source_jar_test",
            ":source_jar_with_srcs_test",
        ],
    )
