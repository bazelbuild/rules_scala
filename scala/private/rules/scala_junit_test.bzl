"""Rules for writing tests with JUnit"""

load("@bazel_skylib//lib:dicts.bzl", _dicts = "dicts")
load(
    "//scala/private:common_attributes.bzl",
    "common_attrs",
    "implicit_deps",
    "launcher_template",
)
load("//scala/private:common_outputs.bzl", "common_outputs")
load("//scala:scala_cross_version.bzl", "scala_version_transition", "toolchain_transition_attr")
load(
    "//scala/private:phases/phases.bzl",
    "extras_phases",
    "phase_collect_jars_junit_test",
    "phase_compile_junit_test",
    "phase_coverage_common",
    "phase_coverage_runfiles",
    "phase_declare_executable",
    "phase_default_info",
    "phase_dependency_common",
    "phase_java_wrapper_common",
    "phase_jvm_flags",
    "phase_merge_jars",
    "phase_runfiles_common",
    "phase_scalac_provider",
    "phase_scalacopts",
    "phase_semanticdb",
    "phase_test_environment",
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
            ("scalac_provider", phase_scalac_provider),
            ("write_manifest", phase_write_manifest),
            ("dependency", phase_dependency_common),
            ("collect_jars", phase_collect_jars_junit_test),
            ("java_wrapper", phase_java_wrapper_common),
            ("declare_executable", phase_declare_executable),
            ("scalacopts", phase_scalacopts),
            ("semanticdb", phase_semanticdb),
            # no need to build an ijar for an executable
            ("compile", phase_compile_junit_test),
            ("coverage", phase_coverage_common),
            ("merge_jars", phase_merge_jars),
            ("runfiles", phase_runfiles_common),
            ("coverage_runfiles", phase_coverage_runfiles),
            ("jvm_flags", phase_jvm_flags),
            ("write_executable", phase_write_executable_junit_test),
            ("default_info", phase_default_info),
            ("test_environment", phase_test_environment),
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
    "runtime_jdk": attr.label(
        default = Label("@bazel_tools//tools/jdk:current_java_runtime"),
        providers = [java_common.JavaRuntimeInfo],
    ),
    "env": attr.string_dict(default = {}),
    "env_inherit": attr.string_list(),
    "_junit_classpath": attr.label(
        default = Label("//testing/toolchain:junit_classpath"),
    ),
    "_bazel_test_runner": attr.label(
        default = Label("//scala:bazel_test_runner_deploy"),
        allow_files = True,
    ),
    "_lcov_merger": attr.label(
        default = Label(
            "@bazel_tools//tools/test/CoverageOutputGenerator/java/com/google/devtools/coverageoutputgenerator:Main",
        ),
    ),
}

_junit_resolve_deps = {
    "_scala_toolchain": attr.label_list(
        default = [
            Label("//scala/private/toolchain_deps:scala_library_classpath"),
            Label("//testing/toolchain:junit_classpath"),
        ],
        allow_files = False,
    ),
}

_scala_junit_test_attrs.update(launcher_template)

_scala_junit_test_attrs.update(implicit_deps)

_scala_junit_test_attrs.update(common_attrs)

_scala_junit_test_attrs.update(_junit_resolve_deps)

_scala_junit_test_attrs.update({
    "tests_from": attr.label_list(providers = [[JavaInfo]]),
})

_scala_junit_test_attrs.update(toolchain_transition_attr)

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
            Label("//scala:toolchain_type"),
            Label("//testing/toolchain:testing_toolchain_type"),
            "@bazel_tools//tools/jdk:toolchain_type",
        ],
        cfg = scala_version_transition,
        incompatible_use_toolchain_transition = True,
        provides = [JavaInfo],
        implementation = _scala_junit_test_impl,
    )

scala_junit_test = make_scala_junit_test()
