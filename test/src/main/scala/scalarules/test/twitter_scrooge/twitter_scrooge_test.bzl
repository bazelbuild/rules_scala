load("@bazel_skylib//lib:collections.bzl", "collections")
load("@bazel_skylib//lib:unittest.bzl", "asserts", "unittest")
load("@rules_java//java/common:java_info.bzl", "JavaInfo")

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

def test_scrooge_provides_transitive_jars():
    # :scrooge1 depends on thrift2_b and thrift2_a which both depend on thrift3
    # All associated jars must be included in the outputs for IntelliJ resolution to function correctly.
    scrooge_transitive_outputs_test(
        name = "transitive_scrooge_test_scala",
        dep = ":scrooge1",
        expected_jars = [
            "thrift_scrooge_scala.jar",
            "thrift2_a_scrooge_scala.jar",
            "thrift2_b_scrooge_scala.jar",
            "thrift3_scrooge_scala.jar",
        ],
    )
    scrooge_transitive_outputs_test(
        name = "transitive_scrooge_test_scala_and_java",
        dep = ":scrooge1_scala_and_java",
        expected_jars = [
            "thrift3_scrooge_scala.jar",
            "thrift2_a_scrooge_scala.jar",
            "thrift2_b_scrooge_scala.jar",
            "thrift3_scrooge_java.jar",
            "thrift_scrooge_scala.jar",
        ],
    )
    scrooge_transitive_outputs_test(
        name = "transitive_scrooge_test_java",
        dep = ":scrooge1_java",
        expected_jars = [
            "thrift_scrooge_java.jar",
            "thrift2_a_scrooge_java.jar",
            "thrift2_b_scrooge_java.jar",
            "thrift3_scrooge_java.jar",
        ],
    )

def twitter_scrooge_test_suite():
    test_scrooge_provides_transitive_jars()

    native.test_suite(
        name = "twitter_scrooge_tests",
        tests = [
            ":transitive_scrooge_test_scala",
            ":transitive_scrooge_test_java",
        ],
    )
