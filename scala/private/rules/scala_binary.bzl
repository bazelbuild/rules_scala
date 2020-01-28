"""Builds Scala binaries"""

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
    "phase_collect_jars_common",
    "phase_compile_binary",
    "phase_declare_executable",
    "phase_default_info",
    "phase_dependency_common",
    "phase_java_wrapper_common",
    "phase_merge_jars",
    "phase_runfiles_common",
    "phase_scalac_provider",
    "phase_write_executable_common",
    "phase_write_manifest",
    "run_phases",
)

def _scala_binary_impl(ctx):
    return run_phases(
        ctx,
        # customizable phases
        [
            ("scalac_provider", phase_scalac_provider),
            ("write_manifest", phase_write_manifest),
            ("dependency", phase_dependency_common),
            ("collect_jars", phase_collect_jars_common),
            ("java_wrapper", phase_java_wrapper_common),
            ("declare_executable", phase_declare_executable),
            # no need to build an ijar for an executable
            ("compile", phase_compile_binary),
            ("merge_jars", phase_merge_jars),
            ("runfiles", phase_runfiles_common),
            ("write_executable", phase_write_executable_common),
            ("default_info", phase_default_info),
        ],
    )

_scala_binary_attrs = {
    "main_class": attr.string(mandatory = True),
    "classpath_resources": attr.label_list(allow_files = True),
    "jvm_flags": attr.string_list(),
}

_scala_binary_attrs.update(launcher_template)

_scala_binary_attrs.update(implicit_deps)

_scala_binary_attrs.update(common_attrs)

_scala_binary_attrs.update(resolve_deps)

def make_scala_binary(*extras):
    return rule(
        attrs = _dicts.add(
            _scala_binary_attrs,
            extras_phases(extras),
            *[extra["attrs"] for extra in extras if "attrs" in extra]
        ),
        executable = True,
        fragments = ["java"],
        outputs = _dicts.add(
            common_outputs,
            *[extra["outputs"] for extra in extras if "outputs" in extra]
        ),
        toolchains = ["@io_bazel_rules_scala//scala:toolchain_type"],
        implementation = _scala_binary_impl,
    )

scala_binary = make_scala_binary()
