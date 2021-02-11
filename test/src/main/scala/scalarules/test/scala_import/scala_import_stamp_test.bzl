load("@bazel_skylib//lib:unittest.bzl", "analysistest", "asserts")
load("//scala:scala_import.bzl", "scala_import")

def _assert_compile_dep_stamped(ctx):
    env = analysistest.begin(ctx)
    jar = ctx.attr.jar.files.to_list()[0].basename
    target_under_test = analysistest.target_under_test(env)
    stamp_action = analysistest.target_actions(env)[0]

    expected_action_mnemonic = "StampWithIjar"
    actual_action_mnemonic = stamp_action.mnemonic
    asserts.equals(env, expected_action_mnemonic, actual_action_mnemonic)

    expected_input = jar
    actual_input = stamp_action.inputs.to_list()[0].basename
    asserts.equals(env, expected_input, actual_input)

    expected_stamped_output = jar.rstrip(".jar") + "-stamped.jar"
    actual_stamped_output = stamp_action.outputs.to_list()[0].basename
    asserts.equals(env, expected_stamped_output, actual_stamped_output)

    # all compiles jars are stamped
    for dep in target_under_test[JavaInfo].compile_jars.to_list():
        asserts.true(env, dep.basename.endswith("-stamped.jar"))

    # full jars are not stamped
    for dep in target_under_test[JavaInfo].full_compile_jars.to_list():
        asserts.false(env, dep.basename.endswith("-stamped.jar"))

    return analysistest.end(env)

stamp_deps_test = analysistest.make(
    _assert_compile_dep_stamped,
    attrs = {"jar": attr.label(allow_files = True)},
)

def _test_dep_stamp(name, jar):
    scala_import_target_name = "scala_import_for_%s" % name
    scala_import(
        name = scala_import_target_name,
        jars = [jar],
        tags = ["manual"],
    )

    stamp_deps_test(
        name = name,
        jar = jar,
        tags = ["no-ide"],
        target_under_test = scala_import_target_name,
    )

def scala_import_stamping_test_suite(name, jar):
    test_name = "%s_%s" % (name, "stamping_test")
    _test_dep_stamp(
        name = test_name,
        jar = jar,
    )

    native.test_suite(
        name = name,
        tests = [test_name],
    )
