load(
    "@io_bazel_rules_scala//scala:providers.bzl",
    _DepsInfo = "DepsInfo",
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

def _scala_toolchain_impl(ctx):
    dependency_mode = ctx.attr.dependency_mode
    strict_deps_mode = _compute_strict_deps_mode(
        ctx.attr.strict_deps_mode,
        dependency_mode,
    )

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

    if dependency_tracking_method not in ("ast", "high-level"):
        fail("Internal error: invalid dependency_tracking_method " + dependency_tracking_method)

    enable_diagnostics_report = ctx.attr.enable_diagnostics_report

    all_strict_deps_patterns = ctx.attr.dependency_tracking_strict_deps_patterns

    strict_deps_include_patterns = [
        pattern
        for pattern in all_strict_deps_patterns
        if not pattern.startswith("-")
    ]
    strict_deps_exclude_patterns = [
        pattern.lstrip("-")
        for pattern in all_strict_deps_patterns
        if pattern.startswith("-")
    ]

    all_unused_deps_patterns = ctx.attr.dependency_tracking_unused_deps_patterns

    unused_deps_include_patterns = [
        pattern
        for pattern in all_unused_deps_patterns
        if not pattern.startswith("-")
    ]
    unused_deps_exclude_patterns = [
        pattern.lstrip("-")
        for pattern in all_unused_deps_patterns
        if pattern.startswith("-")
    ]

    toolchain = platform_common.ToolchainInfo(
        scalacopts = ctx.attr.scalacopts,
        dep_providers = ctx.attr.dep_providers,
        dependency_mode = dependency_mode,
        strict_deps_mode = strict_deps_mode,
        unused_dependency_checker_mode = unused_dependency_checker_mode,
        dependency_tracking_method = dependency_tracking_method,
        strict_deps_include_patterns = strict_deps_include_patterns,
        strict_deps_exclude_patterns = strict_deps_exclude_patterns,
        unused_deps_include_patterns = unused_deps_include_patterns,
        unused_deps_exclude_patterns = unused_deps_exclude_patterns,
        scalac_jvm_flags = ctx.attr.scalac_jvm_flags,
        scala_test_jvm_flags = ctx.attr.scala_test_jvm_flags,
        enable_diagnostics_report = enable_diagnostics_report,
        jacocorunner = ctx.attr.jacocorunner,
    )
    return [toolchain]

scala_toolchain = rule(
    _scala_toolchain_impl,
    attrs = {
        "scalacopts": attr.string_list(),
        "dep_providers": attr.label_list(
            default = [
                "@io_bazel_rules_scala//scala:scala_xml_provider",
                "@io_bazel_rules_scala//scala:parser_combinators_provider",
                "@io_bazel_rules_scala//scala:scala_compile_classpath_provider",
                "@io_bazel_rules_scala//scala:scala_library_classpath_provider",
                "@io_bazel_rules_scala//scala:scala_macro_classpath_provider",
            ],
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
        "dependency_tracking_method": attr.string(
            default = "default",
            values = ["ast", "high-level", "default"],
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
    },
    fragments = ["java"],
)
