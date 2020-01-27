"""Rules for writing tests with ScalaTest"""

load("@bazel_skylib//lib:dicts.bzl", _dicts = "dicts")
load(
    "@io_bazel_rules_scala//scala/private:common_attributes.bzl",
    "common_attrs",
    "implicit_deps",
    "launcher_template",
)
load("@io_bazel_rules_scala//scala/private:common.bzl", "sanitize_string_for_usage")
load("@io_bazel_rules_scala//scala/private:common_outputs.bzl", "common_outputs")
load(
    "@io_bazel_rules_scala//scala/private:phases/phases.bzl",
    "extras_phases",
    "phase_collect_jars_common",
    "phase_compile_scalatest",
    "phase_coverage_runfiles",
    "phase_declare_executable",
    "phase_default_info",
    "phase_java_wrapper_common",
    "phase_merge_jars",
    "phase_runfiles_common",
    "phase_scalac_provider",
    "phase_unused_deps_checker",
    "phase_discover_tests",
    "phase_write_manifest",
    "phase_write_executable_common",
    "run_phases",
)

def _scala_test_impl(ctx):
    return run_phases(
        ctx,
        # customizable phases
        [
            ("scalac_provider", phase_scalac_provider),
            ("write_manifest", phase_write_manifest),
            ("unused_deps_checker", phase_unused_deps_checker),
            ("collect_jars", phase_collect_jars_common),
            ("java_wrapper", phase_java_wrapper_common),
            ("declare_executable", phase_declare_executable),
            # no need to build an ijar for an executable
            ("compile", phase_compile_scalatest),
            ("merge_jars", phase_merge_jars),
            ("discover_tests", phase_discover_tests),
            ("runfiles", phase_runfiles_common),
            ("coverage_runfiles", phase_coverage_runfiles),
            ("write_executable", phase_write_executable_common),
            ("default_info", phase_default_info),
        ],
    )

_scala_test_attrs = {
    "_main_class": attr.string(
        default = "io.bazel.rules_scala.discover_tests_runner.DiscoverTestsRunner",
    ),
    "colors": attr.bool(default = True),
    "full_stacktraces": attr.bool(default = True),
    "jvm_flags": attr.string_list(),
    "_jacocorunner": attr.label(
        default = Label("@bazel_tools//tools/jdk:JacocoCoverage"),
    ),
    "_lcov_merger": attr.label(
        default = Label("@bazel_tools//tools/test/CoverageOutputGenerator/java/com/google/devtools/coverageoutputgenerator:Main"),
    ),
    "_discover_tests_worker": attr.label(
        default = Label("@io_bazel_rules_scala//src/scala/io/bazel/rules_scala/discover_tests_worker"),
    ),
}

_scala_test_attrs.update(launcher_template)

_scala_test_attrs.update(implicit_deps)

_scala_test_attrs.update(common_attrs)

def make_scala_test(*extras):
    return rule(
        attrs = _dicts.add(
            _scala_test_attrs,
            extras_phases(extras),
            *[extra["attrs"] for extra in extras if "attrs" in extra]
        ),
        executable = True,
        fragments = ["java"],
        outputs = _dicts.add(
            common_outputs,
            *[extra["outputs"] for extra in extras if "outputs" in extra]
        ),
        test = True,
        toolchains = ["@io_bazel_rules_scala//scala:toolchain_type"],
        implementation = _scala_test_impl,
    )
