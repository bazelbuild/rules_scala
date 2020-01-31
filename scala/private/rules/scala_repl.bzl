"""Rule for launching a Scala REPL with dependencies"""

load("@bazel_skylib//lib:dicts.bzl", _dicts = "dicts")
load(
    "@io_bazel_rules_scala//scala/private:common_attributes.bzl",
    "common_attrs",
    "implicit_deps",
    "launcher_template",
    "resolve_deps",
)
load("@io_bazel_rules_scala//scala/private:common_outputs.bzl", "common_outputs")
load(
    "@io_bazel_rules_scala//scala/private:phases/phases.bzl",
    "extras_phases",
    "phase_collect_jars_repl",
    "phase_compile_repl",
    "phase_declare_executable",
    "phase_default_info",
    "phase_java_wrapper_repl",
    "phase_merge_jars",
    "phase_runfiles_common",
    "phase_unused_deps_checker",
    "phase_write_executable_repl",
    "phase_write_manifest",
    "run_phases",
)

def _scala_repl_impl(ctx):
    return run_phases(
        ctx,
        # customizable phases
        [
            ("write_manifest", phase_write_manifest),
            ("unused_deps_checker", phase_unused_deps_checker),
            # need scala-compiler for MainGenericRunner below
            ("collect_jars", phase_collect_jars_repl),
            ("java_wrapper", phase_java_wrapper_repl),
            ("declare_executable", phase_declare_executable),
            # no need to build an ijar for an executable
            ("compile", phase_compile_repl),
            ("merge_jars", phase_merge_jars),
            ("runfiles", phase_runfiles_common),
            ("write_executable", phase_write_executable_repl),
            ("default_info", phase_default_info),
        ],
    )

_scala_repl_attrs = {
    "jvm_flags": attr.string_list(),
}

_scala_repl_attrs.update(launcher_template)

_scala_repl_attrs.update(implicit_deps)

_scala_repl_attrs.update(common_attrs)

_scala_repl_attrs.update(resolve_deps)

def make_scala_repl(*extras):
    return rule(
        attrs = _dicts.add(
            _scala_repl_attrs,
            extras_phases(extras),
            *[extra["attrs"] for extra in extras if "attrs" in extra]
        ),
        executable = True,
        fragments = ["java"],
        outputs = _dicts.add(
            common_outputs,
            *[extra["outputs"] for extra in extras if "outputs" in extra]
        ),
        toolchains = [
            "@io_bazel_rules_scala//scala:bootstrap_toolchain_type",
            "@io_bazel_rules_scala//scala:toolchain_type"
        ],
        implementation = _scala_repl_impl,
    )

scala_repl = make_scala_repl()
