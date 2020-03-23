load(
    "@io_bazel_rules_scala//scala:providers.bzl",
    _ScalacProvider = "ScalacProvider",
)

def _compute_dependency_mode(input_dependency_mode):
    if input_dependency_mode == "":
        return "direct"

    return input_dependency_mode

def _compute_strict_deps_mode(input_strict_deps_mode, dependency_mode):
    if dependency_mode == "direct":
        return "off"
    if input_strict_deps_mode == "default":
        if dependency_mode == "transitive":
            return "error"
        else:
            return "off"
    return input_strict_deps_mode

def _compute_dependency_tracking_method(input_dependency_tracking_method):
    if input_dependency_tracking_method == "default":
        return "high-level"
    return input_dependency_tracking_method

def _scala_toolchain_impl(ctx):
    if ctx.fragments.java.strict_java_deps != "default" and ctx.fragments.java.strict_java_deps != "off":
        dependency_mode = "transitive"
        strict_deps_mode = ctx.fragments.java.strict_java_deps
        unused_dependency_checker_mode = "off"
        dependency_tracking_method = "high-level"
    else:
        dependency_mode = _compute_dependency_mode(
            ctx.attr.dependency_mode
        )
        strict_deps_mode = _compute_strict_deps_mode(
            ctx.attr.strict_deps_mode,
            dependency_mode,
        )

        unused_dependency_checker_mode = ctx.attr.unused_dependency_checker_mode
        dependency_tracking_method = _compute_dependency_tracking_method(ctx.attr.dependency_tracking_method)

    # Final quality checks to possibly detect buggy code above
    if dependency_mode not in ("direct", "plus-one", "transitive"):
        fail("Internal error: invalid dependency_mode " + dependency_mode)

    if strict_deps_mode not in ("off", "warn", "error"):
        fail("Internal error: invalid strict_deps_mode " + strict_deps_mode)

    if dependency_tracking_method not in ("ast", "high-level"):
        fail("Internal error: invalid dependency_tracking_method " + dependency_tracking_method)

    toolchain = platform_common.ToolchainInfo(
        scalacopts = ctx.attr.scalacopts,
        scalac_provider_attr = ctx.attr.scalac_provider_attr,
        dependency_mode = dependency_mode,
        strict_deps_mode = strict_deps_mode,
        unused_dependency_checker_mode = unused_dependency_checker_mode,
        dependency_tracking_method = dependency_tracking_method,
        enable_code_coverage_aspect = ctx.attr.enable_code_coverage_aspect,
        scalac_jvm_flags = ctx.attr.scalac_jvm_flags,
        scala_test_jvm_flags = ctx.attr.scala_test_jvm_flags,
    )
    return [toolchain]

scala_toolchain = rule(
    _scala_toolchain_impl,
    attrs = {
        "scalacopts": attr.string_list(),
        "scalac_provider_attr": attr.label(
            default = "@io_bazel_rules_scala//scala:scalac_default",
            providers = [_ScalacProvider],
        ),
        "dependency_mode": attr.string(
            values = ["direct", "plus-one", "transitive", ""],
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
        "enable_code_coverage_aspect": attr.string(
            default = "off",
            values = ["off", "on"],
        ),
        "scalac_jvm_flags": attr.string_list(),
        "scala_test_jvm_flags": attr.string_list(),
    },
    fragments = ["java"],
)
