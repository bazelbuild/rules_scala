load("@bazel_skylib//lib:unittest.bzl", "analysistest", "asserts")
load("@rules_java//java/common:java_info.bzl", "JavaInfo")
load("//scala:scala_import.bzl", "scala_import")
load("//scala/settings:stamp_settings.bzl", "stamp_scala_import")

def _assert_compile_dep_stamped(ctx):
    env = analysistest.begin(ctx)
    stamping_enabled = ctx.attr.stamp
    jar = ctx.attr.jar.files.to_list()[0].basename
    expected_action_mnemonic = "JavaIjar"
    expected_input = jar
    expected_stamped_output = jar.rstrip(".jar") + "-stamped.jar"

    target_under_test = analysistest.target_under_test(env)

    if stamping_enabled:
        stamp_action = analysistest.target_actions(env)[1]

        actual_action_mnemonic = stamp_action.mnemonic
        asserts.equals(env, expected_action_mnemonic, actual_action_mnemonic)

        actual_input = stamp_action.inputs.to_list()[0].basename
        asserts.equals(env, expected_input, actual_input)

        actual_stamped_output = stamp_action.outputs.to_list()[0].basename
        asserts.equals(env, expected_stamped_output, actual_stamped_output)

    # all compiles jars are stamped
    for dep in target_under_test[JavaInfo].compile_jars.to_list():
        asserts.equals(
            env,
            expected_stamped_output if stamping_enabled else jar,
            dep.basename,
            "compile jar",
        )

    # full jars are not stamped
    for dep in target_under_test[JavaInfo].full_compile_jars.to_list():
        asserts.equals(
            env,
            jar,
            dep.basename,
            "runtime jar",
        )

    return analysistest.end(env)

stamp_deps_test = analysistest.make(
    _assert_compile_dep_stamped,
    attrs = {"jar": attr.label(allow_files = True), "stamp": attr.bool()},
)

def _test_dep_stamp(suite, name, jar, stamp_on):
    test_name = "%s_%s_%s" % (suite, name, stamp_on)

    setting_name = "stamp_scala_import_%s" % stamp_on

    stamp_scala_import(
        name = setting_name,
        build_setting_default = stamp_on,
        visibility = ["//visibility:public"],
    )

    scala_import_target_name = "scala_import_for_%s" % test_name
    scala_import(
        name = scala_import_target_name,
        jars = [jar],
        tags = ["manual"],
        stamp = setting_name,
    )

    stamp_deps_test(
        name = test_name,
        jar = jar,
        stamp = stamp_on,
        tags = ["no-ide"],
        target_under_test = scala_import_target_name,
    )

    return test_name

def scala_import_stamping_test_suite(name, jar):
    test_with_stamping = _test_dep_stamp(
        suite = name,
        name = "stamping_test",
        jar = jar,
        stamp_on = True,
    )

    test_without_stamping = _test_dep_stamp(
        suite = name,
        name = "stamping_test",
        jar = jar,
        stamp_on = False,
    )

    native.test_suite(
        name = name,
        tests = [test_with_stamping, test_without_stamping],
    )
