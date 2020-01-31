load("@bazel_skylib//lib:unittest.bzl", "asserts", "unittest")
load("//twitter_scrooge:twitter_scrooge.bzl", "scrooge_scala_library")
load("//thrift:thrift.bzl", "thrift_library")

def _scrooge_transitive_outputs(ctx):
    env = unittest.begin(ctx)

    asserts.set_equals(
        env,
        depset([
            "thrift_scrooge.jar",
            "thrift2_a_scrooge.jar",
            "thrift2_b_scrooge.jar",
            "thrift3_scrooge.jar",
        ]),
        depset([out.class_jar.basename for out in ctx.attr.dep[JavaInfo].outputs.jars]),
    )

    return unittest.end(env)

scrooge_transitive_outputs_test = unittest.make(
    _scrooge_transitive_outputs,
    attrs = {"dep": attr.label()},
)

def test_scrooge_provides_transitive_jars():
    # :scrooge1 depends on thrift2_b and thrift2_a which both depend on thrift3
    # All associated jars must be included in the outputs for IntelliJ resolution to function correctly.
    scrooge_transitive_outputs_test(
        name = "transitive_scrooge_test",
        dep = ":scrooge1",
    )

def twitter_scrooge_test_suite():
    test_scrooge_provides_transitive_jars()

    native.test_suite(
        name = "twitter_scrooge_tests",
        tests = [
            ":transitive_scrooge_test",
        ],
    )
