# Gathers information about dependency mode and analysis

load(
    "@io_bazel_rules_scala//scala/private:dependency.bzl",
    "get_strict_deps_mode",
    "new_dependency_info",
)
load(
    "@io_bazel_rules_scala//scala/private:paths.bzl",
    _get_files_with_extension = "get_files_with_extension",
    _java_extension = "java_extension",
)

def phase_dependency_common(ctx, p):
    return _phase_dependency_default(ctx, p)

def phase_dependency_library_for_plugin_bootstrapping(ctx, p):
    args = struct(
        unused_deps_always_off = True,
        strict_deps_always_off = True,
    )
    return _phase_dependency_default(ctx, p, args)

def _phase_dependency_default(ctx, p, args = struct()):
    return _phase_dependency(
        ctx,
        p,
        args.unused_deps_always_off if hasattr(args, "unused_deps_always_off") else False,
        args.strict_deps_always_off if hasattr(args, "strict_deps_always_off") else False,
    )

def _phase_dependency(
        ctx,
        p,
        unused_deps_always_off,
        strict_deps_always_off):
    toolchain = ctx.toolchains["@io_bazel_rules_scala//scala:toolchain_type"]

    target_label = str(ctx.label)

    included_in_strict_deps_analysis = _is_target_included(
        target_label,
        toolchain.strict_deps_include_patterns,
        toolchain.strict_deps_exclude_patterns,
    )

    included_in_unused_deps_analysis = _is_target_included(
        target_label,
        toolchain.unused_deps_include_patterns,
        toolchain.unused_deps_exclude_patterns,
    )

    if strict_deps_always_off or not included_in_strict_deps_analysis:
        strict_deps_mode = "off"
    else:
        strict_deps_mode = get_strict_deps_mode(ctx)

    if unused_deps_always_off or not included_in_unused_deps_analysis:
        unused_deps_mode = "off"
    else:
        unused_deps_mode = _get_unused_deps_mode(ctx)

    # We are not able to verify whether dependencies are used when compiling java sources
    # Thus we disable unused dependency checking when java sources are found
    java_srcs = _get_files_with_extension(ctx, _java_extension)
    if len(java_srcs) != 0:
        unused_deps_mode = "off"

    return new_dependency_info(
        toolchain.dependency_mode,
        unused_deps_mode,
        strict_deps_mode,
        toolchain.dependency_tracking_method,
    )

def _get_unused_deps_mode(ctx):
    if ctx.attr.unused_dependency_checker_mode:
        return ctx.attr.unused_dependency_checker_mode
    else:
        return ctx.toolchains["@io_bazel_rules_scala//scala:toolchain_type"].unused_dependency_checker_mode

def _is_target_included(target, includes, excludes):
    if len([exclude for exclude in excludes if target.startswith(exclude)]) > 0:
        return False

    return len([include for include in includes if target.startswith(include)]) > 0
