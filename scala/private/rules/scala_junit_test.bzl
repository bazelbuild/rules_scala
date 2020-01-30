"""Rules for writing tests with JUnit"""

load("@bazel_skylib//lib:dicts.bzl", _dicts = "dicts")
load(
    "@io_bazel_rules_scala//scala/private:common_attributes.bzl",
    "common_attrs",
    "implicit_deps",
    "launcher_template",
)
load("@io_bazel_rules_scala//scala/private:common_outputs.bzl", "common_outputs")
load(
    "@io_bazel_rules_scala//scala/private:phases/phases.bzl",
    "extras_phases",
    "phase_collect_jars_junit_test",
    "phase_compile_junit_test",
    "phase_declare_executable",
    "phase_default_info",
    "phase_java_wrapper_common",
    "phase_jvm_flags",
    "phase_merge_jars",
    "phase_runfiles_common",
    "phase_unused_deps_checker",
    "phase_write_executable_junit_test",
    "phase_write_manifest",
    "run_phases",
)

def _scala_junit_test_impl(ctx):
    if (not (ctx.attr.prefixes) and not (ctx.attr.suffixes)):
        fail(
            "Setting at least one of the attributes ('prefixes','suffixes') is required",
        )
    return run_phases(
        ctx,
        # customizable phases
        [
            ("write_manifest", phase_write_manifest),
            ("unused_deps_checker", phase_unused_deps_checker),
            ("collect_jars", phase_collect_jars_junit_test),
            ("java_wrapper", phase_java_wrapper_common),
            ("declare_executable", phase_declare_executable),
            # no need to build an ijar for an executable
            ("compile", phase_compile_junit_test),
            ("merge_jars", phase_merge_jars),
            ("runfiles", phase_runfiles_common),
            ("jvm_flags", phase_jvm_flags),
            ("write_executable", phase_write_executable_junit_test),
            ("default_info", phase_default_info),
        ],
    )

_scala_junit_test_attrs = {
    "prefixes": attr.string_list(default = []),
    "suffixes": attr.string_list(default = []),
    "suite_label": attr.label(
        default = Label(
            "//src/java/io/bazel/rulesscala/test_discovery:test_discovery",
        ),
    ),
    "suite_class": attr.string(
        default = "io.bazel.rulesscala.test_discovery.DiscoveredTestSuite",
    ),
    "print_discovered_classes": attr.bool(
        default = False,
        mandatory = False,
    ),
    "jvm_flags": attr.string_list(),
    "_junit": attr.label(
        default = Label(
            "//external:io_bazel_rules_scala/dependency/junit/junit",
        ),
    ),
    "_hamcrest": attr.label(
        default = Label(
            "//external:io_bazel_rules_scala/dependency/hamcrest/hamcrest_core",
        ),
    ),
    "_bazel_test_runner": attr.label(
        default = Label(
            "@io_bazel_rules_scala//scala:bazel_test_runner_deploy",
        ),
        allow_files = True,
    ),
}

_junit_resolve_deps = {
    # "_scala_toolchain": attr.label_list(
    #     default = [
    #         Label(
    #             "//external:io_bazel_rules_scala/dependency/scala/scala_library",
    #         ),
    #         Label("//external:io_bazel_rules_scala/dependency/junit/junit"),
    #         Label(
    #             "//external:io_bazel_rules_scala/dependency/hamcrest/hamcrest_core",
    #         ),
    #     ],
    #     allow_files = False,
    # ),
}

_scala_junit_test_attrs.update(launcher_template)

_scala_junit_test_attrs.update(implicit_deps)

_scala_junit_test_attrs.update(common_attrs)

_scala_junit_test_attrs.update(_junit_resolve_deps)

_scala_junit_test_attrs.update({
    "tests_from": attr.label_list(providers = [[JavaInfo]]),
})

def make_scala_junit_test(*extras):
    return rule(
        attrs = _dicts.add(
            _scala_junit_test_attrs,
            extras_phases(extras),
            *[extra["attrs"] for extra in extras if "attrs" in extra]
        ),
        fragments = ["java"],
        outputs = _dicts.add(
            common_outputs,
            *[extra["outputs"] for extra in extras if "outputs" in extra]
        ),
        test = True,
        toolchains = [
            "@io_bazel_rules_scala//scala:bootstrap_toolchain_type",
            "@io_bazel_rules_scala//scala:toolchain_type",
            # unclear on next and will consider in factoring, whether
            # scalatest and junit tests should be different toolchain types
            "@io_bazel_rules_scala//scala:test_toolchain_type",
        ],
        implementation = _scala_junit_test_impl,
    )

scala_junit_test = make_scala_junit_test()
