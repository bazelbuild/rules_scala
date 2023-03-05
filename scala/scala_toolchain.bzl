load(
    "@io_bazel_rules_scala//scala:providers.bzl",
    _DepsInfo = "DepsInfo",
)
load(
    "@io_bazel_rules_scala_config//:config.bzl",
    "ENABLE_COMPILER_DEPENDENCY_TRACKING",
    "SCALA_MAJOR_VERSION",
)

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
    enable_semanticdb = ctx.attr.enable_semanticdb

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
        enable_semanticdb = enable_semanticdb,
        use_argument_file_in_runner = ctx.attr.use_argument_file_in_runner,
    )
    return [toolchain]

def _default_dep_providers():
    dep_providers = [
        "@io_bazel_rules_scala//scala:scala_xml_provider",
        "@io_bazel_rules_scala//scala:parser_combinators_provider",
        "@io_bazel_rules_scala//scala:scala_compile_classpath_provider",
        "@io_bazel_rules_scala//scala:scala_library_classpath_provider",
        "@io_bazel_rules_scala//scala:scala_macro_classpath_provider",
    ]
    if SCALA_MAJOR_VERSION.startswith("2"):
        dep_providers.append("@io_bazel_rules_scala//scala:semanticdb_scalac_provider")
    return dep_providers

scala_toolchain = rule(
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
            doc = "List of target prefixes included for strict deps analysis. Exclude patetrns with '-'",
            default = [""],
        ),
        "dependency_tracking_unused_deps_patterns": attr.string_list(
            doc = "List of target prefixes included for unused deps analysis. Exclude patetrns with '-'",
            default = [""],
        ),
        "scalac_jvm_flags": attr.string_list(),
        "scala_test_jvm_flags": attr.string_list(),
        "enable_diagnostics_report": attr.bool(
            doc = "Enable the output of structured diagnostics through the BEP",
        ),
        "jacocorunner": attr.label(
            default = Label("@bazel_tools//tools/jdk:JacocoCoverage"),
        ),
        "enable_stats_file": attr.bool(
            default = True,
            doc = "Enable writing of statsfile",
        ),
        "enable_semanticdb": attr.bool(
            default = False,
            doc = "Enable SemanticDb",
        ),
        "use_argument_file_in_runner": attr.bool(
            default = False,
            doc = "Changes java binaries scripts (including tests) to use argument files and not classpath jars to improve performance, requires java > 8",
        ),
    },
    fragments = ["java"],
)
