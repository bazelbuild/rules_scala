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
    "phase_common_java_wrapper",
    "phase_coverage_runfiles",
    "phase_declare_executable",
    "phase_merge_jars",
    "phase_scalac_provider",
    "phase_scalatest_collect_jars",
    "phase_scalatest_compile",
    "phase_scalatest_default_info",
    "phase_scalatest_runfiles",
    "phase_scalatest_write_executable",
    "phase_unused_deps_checker",
    "phase_write_manifest",
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
            ("collect_jars", phase_scalatest_collect_jars),
            ("java_wrapper", phase_common_java_wrapper),
            ("declare_executable", phase_declare_executable),
            # no need to build an ijar for an executable
            ("compile", phase_scalatest_compile),
            ("merge_jars", phase_merge_jars),
            ("runfiles", phase_scalatest_runfiles),
            ("coverage_runfiles", phase_coverage_runfiles),
            ("write_executable", phase_scalatest_write_executable),
            ("default_info", phase_scalatest_default_info),
        ],
    )

_scala_test_attrs = {
    "main_class": attr.string(
        default = "io.bazel.rulesscala.scala_test.Runner",
    ),
    "colors": attr.bool(default = True),
    "full_stacktraces": attr.bool(default = True),
    "jvm_flags": attr.string_list(),
    "_scalatest": attr.label(
        default = Label(
            "//external:io_bazel_rules_scala/dependency/scalatest/scalatest",
        ),
    ),
    "_scalatest_runner": attr.label(
        cfg = "host",
        default = Label("//src/java/io/bazel/rulesscala/scala_test:runner"),
    ),
    "_scalatest_reporter": attr.label(
        default = Label("//scala/support:test_reporter"),
    ),
    "_jacocorunner": attr.label(
        default = Label("@bazel_tools//tools/jdk:JacocoCoverage"),
    ),
    "_lcov_merger": attr.label(
        default = Label("@bazel_tools//tools/test/CoverageOutputGenerator/java/com/google/devtools/coverageoutputgenerator:Main"),
    ),
}

_test_resolve_deps = {
    "_scala_toolchain": attr.label_list(
        default = [
            Label(
                "//external:io_bazel_rules_scala/dependency/scala/scala_library",
            ),
            Label(
                "//external:io_bazel_rules_scala/dependency/scalatest/scalatest",
            ),
        ],
        allow_files = False,
    ),
}

_scala_test_attrs.update(launcher_template)

_scala_test_attrs.update(implicit_deps)

_scala_test_attrs.update(common_attrs)

_scala_test_attrs.update(_test_resolve_deps)

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

scala_test = make_scala_test()

# This auto-generates a test suite based on the passed set of targets
# we will add a root test_suite with the name of the passed name
def scala_test_suite(
        name,
        srcs = [],
        visibility = None,
        use_short_names = False,
        **kwargs):
    ts = []
    i = 0
    for test_file in srcs:
        i = i + 1
        n = ("%s_%s" % (name, i)) if use_short_names else ("%s_test_suite_%s" % (name, sanitize_string_for_usage(test_file)))
        scala_test(
            name = n,
            srcs = [test_file],
            visibility = visibility,
            unused_dependency_checker_mode = "off",
            **kwargs
        )
        ts.append(n)
    native.test_suite(name = name, tests = ts, visibility = visibility)
