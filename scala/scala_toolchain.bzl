load("@bazel_skylib//rules:common_settings.bzl", "BuildSettingInfo")
load(
    "@rules_scala_config//:config.bzl",
    "ENABLE_COMPILER_DEPENDENCY_TRACKING",
    "SCALA_MAJOR_VERSION",
)
load("//scala:providers.bzl", _DepsInfo = "DepsInfo")

def _compute_strict_deps_mode(input_strict_deps_mode, dependency_mode):
    if dependency_mode == "direct":
        return "off"
    if input_strict_deps_mode == "default":
        if dependency_mode == "transitive":
            return "error"
        else:
            return "off"
    return input_strict_deps_mode

def _compute_dependency_tracking_method(
        dependency_mode,
        input_dependency_tracking_method):
    if input_dependency_tracking_method == "default":
        if dependency_mode == "direct":
            return "high-level"
        else:
            return "ast"
    return input_dependency_tracking_method

def _partition_patterns(patterns):
    includes = [
        pattern
        for pattern in patterns
        if not pattern.startswith("-")
    ]
    excludes = [
        pattern.lstrip("-")
        for pattern in patterns
        if pattern.startswith("-")
    ]
    return includes, excludes

def _scala_toolchain_impl(ctx):
    dependency_mode = ctx.attr.dependency_mode
    strict_deps_mode = _compute_strict_deps_mode(
        ctx.attr.strict_deps_mode,
        dependency_mode,
    )

    compiler_deps_mode = ctx.attr.compiler_deps_mode

    unused_dependency_checker_mode = ctx.attr.unused_dependency_checker_mode
    dependency_tracking_method = _compute_dependency_tracking_method(
        dependency_mode,
        ctx.attr.dependency_tracking_method,
    )

    # Final quality checks to possibly detect buggy code above
    if dependency_mode not in ("direct", "plus-one", "transitive"):
        fail("Internal error: invalid dependency_mode " + dependency_mode)

    if strict_deps_mode not in ("off", "warn", "error"):
        fail("Internal error: invalid strict_deps_mode " + strict_deps_mode)

    if compiler_deps_mode not in ("off", "warn", "error"):
        fail("Internal error: invalid compiler_deps_mode " + compiler_deps_mode)

    if dependency_tracking_method not in ("ast-plus", "ast", "high-level"):
        fail("Internal error: invalid dependency_tracking_method " + dependency_tracking_method)

    if "ast-plus" == dependency_tracking_method and not ENABLE_COMPILER_DEPENDENCY_TRACKING:
        fail("To use 'ast-plus' dependency tracking, you must set 'enable_compiler_dependency_tracking' to True in scala_config")

    enable_stats_file = ctx.attr.enable_stats_file
    enable_diagnostics_report = ctx.attr.enable_diagnostics_report

    all_strict_deps_patterns = ctx.attr.dependency_tracking_strict_deps_patterns
    strict_deps_includes, strict_deps_excludes = _partition_patterns(all_strict_deps_patterns)

    all_unused_deps_patterns = ctx.attr.dependency_tracking_unused_deps_patterns
    unused_deps_includes, unused_deps_excludes = _partition_patterns(all_unused_deps_patterns)

    toolchain = platform_common.ToolchainInfo(
        scalacopts = ctx.attr.scalacopts,
        dep_providers = ctx.attr.dep_providers,
        dependency_mode = dependency_mode,
        strict_deps_mode = strict_deps_mode,
        unused_dependency_checker_mode = unused_dependency_checker_mode,
        compiler_deps_mode = compiler_deps_mode,
        dependency_tracking_method = dependency_tracking_method,
        strict_deps_include_patterns = strict_deps_includes,
        strict_deps_exclude_patterns = strict_deps_excludes,
        unused_deps_include_patterns = unused_deps_includes,
        unused_deps_exclude_patterns = unused_deps_excludes,
        scalac_jvm_flags = ctx.attr.scalac_jvm_flags,
        scala_test_jvm_flags = ctx.attr.scala_test_jvm_flags,
        enable_diagnostics_report = enable_diagnostics_report,
        jacocorunner = ctx.attr.jacocorunner,
        enable_stats_file = enable_stats_file,
        enable_semanticdb = ctx.attr.enable_semanticdb,
        semanticdb_bundle_in_jar = ctx.attr.semanticdb_bundle_in_jar,
        use_argument_file_in_runner = ctx.attr.use_argument_file_in_runner,
        scala_version = ctx.attr._scala_version[BuildSettingInfo].value,
    )
    return [toolchain]

def _default_dep_providers():
    dep_providers = [
        "scala_xml",
        "parser_combinators",
        "scala_compile_classpath",
        "scala_library_classpath",
        "scala_macro_classpath",
    ]
    if SCALA_MAJOR_VERSION.startswith("2."):
        dep_providers.append("semanticdb")
    return [
        "@rules_scala_toolchains//scala:%s_provider" % p
        for p in dep_providers
    ]

_scala_toolchain = rule(
    _scala_toolchain_impl,
    attrs = {
        "scalacopts": attr.string_list(),
        "dep_providers": attr.label_list(
            default = _default_dep_providers(),
            providers = [_DepsInfo],
        ),
        "dependency_mode": attr.string(
            default = "direct",
            values = ["direct", "plus-one", "transitive"],
        ),
        "strict_deps_mode": attr.string(
            default = "default",
            values = ["off", "warn", "error", "default"],
        ),
        "unused_dependency_checker_mode": attr.string(
            default = "off",
            values = ["off", "warn", "error"],
        ),
        "compiler_deps_mode": attr.string(
            default = "off",
            values = ["off", "warn", "error"],
        ),
        "dependency_tracking_method": attr.string(
            default = "default",
            values = ["ast-plus", "ast", "high-level", "default"],
        ),
        "dependency_tracking_strict_deps_patterns": attr.string_list(
            doc = "List of target prefixes included for strict deps analysis. Exclude patterns with '-'",
            default = [""],
        ),
        "dependency_tracking_unused_deps_patterns": attr.string_list(
            doc = "List of target prefixes included for unused deps analysis. Exclude patterns with '-'",
            default = [""],
        ),
        "scalac_jvm_flags": attr.string_list(),
        "scala_test_jvm_flags": attr.string_list(),
        "enable_diagnostics_report": attr.bool(
            doc = "Enable the output of structured diagnostics through the BEP",
        ),
        "jacocorunner": attr.label(
            default = "@bazel_tools//tools/jdk:JacocoCoverage",
        ),
        "enable_stats_file": attr.bool(
            default = True,
            doc = "Enable writing of statsfile",
        ),
        "enable_semanticdb": attr.bool(
            default = False,
            doc = "Enable SemanticDb",
        ),
        "semanticdb_bundle_in_jar": attr.bool(default = False, doc = "Option to bundle the semanticdb files inside the output jar file"),
        "use_argument_file_in_runner": attr.bool(
            default = False,
            doc = "Changes java binaries scripts (including tests) to use argument files and not classpath jars to improve performance, requires java > 8",
        ),
        "_scala_version": attr.label(
            default = "@rules_scala_config//:scala_version",
        ),
    },
    fragments = ["java"],
)

def _expand_patterns(patterns):
    """Expands string patterns to match actual Label values."""
    result = []

    for p in patterns:
        exclude = p.startswith("-")
        p = p.lstrip("-")
        expanded = str(native.package_relative_label(p)) if p else ""

        # If the original pattern doesn't contain ":", match any target
        # beginning with the pattern prefix.
        if expanded and ":" not in p:
            expanded = expanded[:expanded.rindex(":")]

        result.append(("-" if exclude else "") + expanded)

    return result

def scala_toolchain(**kwargs):
    """Creates a Scala toolchain target."""
    strict = kwargs.pop("dependency_tracking_strict_deps_patterns", [""])
    unused = kwargs.pop("dependency_tracking_unused_deps_patterns", [""])
    _scala_toolchain(
        dependency_tracking_strict_deps_patterns = _expand_patterns(strict),
        dependency_tracking_unused_deps_patterns = _expand_patterns(unused),
        **kwargs
    )
