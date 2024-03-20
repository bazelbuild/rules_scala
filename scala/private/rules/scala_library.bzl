load("@bazel_skylib//lib:dicts.bzl", _dicts = "dicts")
load(
    "@io_bazel_rules_scala//scala/private:common.bzl",
    "sanitize_string_for_usage",
)
load(
    "@io_bazel_rules_scala//scala/private:common_attributes.bzl",
    "common_attrs",
    "common_attrs_for_plugin_bootstrapping",
    "implicit_deps",
    "resolve_deps",
)
load("@io_bazel_rules_scala//scala/private:common_outputs.bzl", "common_outputs")
load(
    "@io_bazel_rules_scala//scala/private:coverage_replacements_provider.bzl",
    _coverage_replacements_provider = "coverage_replacements_provider",
)
load("@io_bazel_rules_scala_config//:config.bzl", "SCALA_VERSIONS")
load("@io_bazel_rules_scala//scala:scala_cross_version.bzl", "version_suffix")
load(
    "@io_bazel_rules_scala//scala/private:phases/phases.bzl",
    "extras_phases",
    "phase_collect_exports_jars",
    "phase_collect_jars_common",
    "phase_collect_jars_macro_library",
    "phase_collect_srcjars",
    "phase_compile_library",
    "phase_compile_library_for_plugin_bootstrapping",
    "phase_compile_macro_library",
    "phase_coverage_common",
    "phase_coverage_library",
    "phase_default_info",
    "phase_dependency_common",
    "phase_dependency_library_for_plugin_bootstrapping",
    "phase_merge_jars",
    "phase_runfiles_library",
    "phase_scalac_provider",
    "phase_scalacopts",
    "phase_semanticdb",
    "phase_write_manifest",
    "run_phases",
)

##
# Common stuff to _library rules
##

_library_attrs = {
    "main_class": attr.string(),
    "exports": attr.label_list(
        allow_files = False,
        aspects = [_coverage_replacements_provider.aspect],
    ),
}

##
# scala_library
##

def _scala_library_impl(ctx):
    # Build up information from dependency-like attributes
    return run_phases(
        ctx,
        # customizable phases
        [
            ("scalac_provider", phase_scalac_provider),
            ("collect_srcjars", phase_collect_srcjars),
            ("write_manifest", phase_write_manifest),
            ("dependency", phase_dependency_common),
            ("collect_jars", phase_collect_jars_common),
            ("scalacopts", phase_scalacopts),
            ("semanticdb", phase_semanticdb),
            ("compile", phase_compile_library),
            ("coverage", phase_coverage_library),
            ("merge_jars", phase_merge_jars),
            ("runfiles", phase_runfiles_library),
            ("collect_exports_jars", phase_collect_exports_jars),
            ("default_info", phase_default_info),
        ],
    )

_scala_library_attrs = {}

_scala_library_attrs.update(implicit_deps)

_scala_library_attrs.update(common_attrs)

_scala_library_attrs.update(_library_attrs)

_scala_library_attrs.update(resolve_deps)

def make_scala_library(*extras):
    return rule(
        attrs = _dicts.add(
            _scala_library_attrs,
            extras_phases(extras),
            *[extra["attrs"] for extra in extras if "attrs" in extra]
        ),
        fragments = ["java"],
        outputs = _dicts.add(
            common_outputs,
            *[extra["outputs"] for extra in extras if "outputs" in extra]
        ),
        toolchains = [
            "@io_bazel_rules_scala//scala:toolchain_type",
            "@bazel_tools//tools/jdk:toolchain_type",
        ],
        incompatible_use_toolchain_transition = True,
        implementation = _scala_library_impl,
    )

scala_library = make_scala_library()

# Scala library suite generates a series of scala libraries
# then it depends on them with a meta one which exports all the sub targets
def scala_library_suite(
        name,
        srcs = [],
        exports = [],
        visibility = None,
        **kwargs):
    ts = []
    for src_file in srcs:
        n = "%s_lib_%s" % (name, sanitize_string_for_usage(src_file))
        scala_library(
            name = n,
            srcs = [src_file],
            visibility = visibility,
            exports = exports,
            unused_dependency_checker_mode = "off",
            **kwargs
        )
        ts.append(n)
    scala_library(
        name = name,
        visibility = visibility,
        exports = exports + ts,
        deps = ts,
    )

##
# scala_library_for_plugin_bootstrapping
##

def _scala_library_for_plugin_bootstrapping_impl(ctx):
    return run_phases(
        ctx,
        # customizable phases
        [
            ("scalac_provider", phase_scalac_provider),
            ("collect_srcjars", phase_collect_srcjars),
            ("write_manifest", phase_write_manifest),
            ("dependency", phase_dependency_library_for_plugin_bootstrapping),
            ("collect_jars", phase_collect_jars_common),
            ("scalacopts", phase_scalacopts),
            #("semanticdb", phase_semanticdb), noneed for semanticdb in bootstrap
            ("compile", phase_compile_library_for_plugin_bootstrapping),
            ("merge_jars", phase_merge_jars),
            ("runfiles", phase_runfiles_library),
            ("collect_exports_jars", phase_collect_exports_jars),
            ("default_info", phase_default_info),
        ],
    )

_scala_library_for_plugin_bootstrapping_attrs = {}

_scala_library_for_plugin_bootstrapping_attrs.update(implicit_deps)

# the scala compiler plugin used for dependency analysis is compiled using `scala_library`.
# in order to avoid cyclic dependencies `scala_library_for_plugin_bootstrapping` was created for this purpose,
# which does not contain plugin related attributes, and thus avoids the cyclic dependency issue
_scala_library_for_plugin_bootstrapping_attrs.update({
    "build_ijar": attr.bool(default = True),
    "_scalac": attr.label_list(
        cfg = "exec",
        default = [Label("@io_bazel_rules_scala//src/java/io/bazel/rulesscala/scalac:scalac_bootstrap" + version_suffix(version)) for version in SCALA_VERSIONS],
        allow_files = True,
    ),
})

_scala_library_for_plugin_bootstrapping_attrs.update(_library_attrs)

_scala_library_for_plugin_bootstrapping_attrs.update(resolve_deps)

_scala_library_for_plugin_bootstrapping_attrs.update(
    common_attrs_for_plugin_bootstrapping,
)

def make_scala_library_for_plugin_bootstrapping(*extras):
    return rule(
        attrs = _dicts.add(
            _scala_library_for_plugin_bootstrapping_attrs,
            extras_phases(extras),
            *[extra["attrs"] for extra in extras if "attrs" in extra]
        ),
        fragments = ["java"],
        outputs = _dicts.add(
            common_outputs,
            *[extra["outputs"] for extra in extras if "outputs" in extra]
        ),
        toolchains = [
            "@io_bazel_rules_scala//scala:toolchain_type",
            "@bazel_tools//tools/jdk:toolchain_type",
        ],
        incompatible_use_toolchain_transition = True,
        implementation = _scala_library_for_plugin_bootstrapping_impl,
    )

scala_library_for_plugin_bootstrapping = make_scala_library_for_plugin_bootstrapping()

##
# scala_macro_library
##

def _scala_macro_library_impl(ctx):
    return run_phases(
        ctx,
        # customizable phases
        [
            ("scalac_provider", phase_scalac_provider),
            ("collect_srcjars", phase_collect_srcjars),
            ("write_manifest", phase_write_manifest),
            ("dependency", phase_dependency_common),
            ("collect_jars", phase_collect_jars_macro_library),
            ("scalacopts", phase_scalacopts),
            ("semanticdb", phase_semanticdb),
            ("compile", phase_compile_macro_library),
            ("coverage", phase_coverage_common),
            ("merge_jars", phase_merge_jars),
            ("runfiles", phase_runfiles_library),
            ("collect_exports_jars", phase_collect_exports_jars),
            ("default_info", phase_default_info),
        ],
    )

_scala_macro_library_attrs = {
    "main_class": attr.string(),
    "exports": attr.label_list(allow_files = False),
}

_scala_macro_library_attrs.update(implicit_deps)

_scala_macro_library_attrs.update(common_attrs)

_scala_macro_library_attrs.update(_library_attrs)

_scala_macro_library_attrs.update(resolve_deps)

# Set unused_dependency_checker_mode default to off for scala_macro_library
_scala_macro_library_attrs["unused_dependency_checker_mode"] = attr.string(
    default = "off",
    values = [
        "warn",
        "error",
        "off",
        "",
    ],
    mandatory = False,
)

def make_scala_macro_library(*extras):
    return rule(
        attrs = _dicts.add(
            _scala_macro_library_attrs,
            extras_phases(extras),
            *[extra["attrs"] for extra in extras if "attrs" in extra]
        ),
        fragments = ["java"],
        outputs = _dicts.add(
            common_outputs,
            *[extra["outputs"] for extra in extras if "outputs" in extra]
        ),
        toolchains = [
            "@io_bazel_rules_scala//scala:toolchain_type",
            "@bazel_tools//tools/jdk:toolchain_type",
        ],
        incompatible_use_toolchain_transition = True,
        implementation = _scala_macro_library_impl,
    )

scala_macro_library = make_scala_macro_library()
