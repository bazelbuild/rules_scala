# This file contains all computations for what the dependency mode is
# (i.e. transitive, plus-one, direct, etc)
# and what/how dependency analysis is performed (unused deps, strict deps, etc).

def new_dependency_info(
        dependency_mode,
        unused_deps_mode,
        strict_deps_mode,
        dependency_tracking_method):
    is_strict_deps_on = strict_deps_mode != "off"

    # Currently we do not support running both strict and unused deps at the same time
    if is_strict_deps_on:
        unused_deps_mode = "off"

    is_unused_deps_on = unused_deps_mode != "off"

    need_direct_jars = is_strict_deps_on or is_unused_deps_on
    need_direct_targets = is_unused_deps_on

    return struct(
        dependency_mode = dependency_mode,
        need_indirect_info = is_strict_deps_on,
        need_direct_jars = need_direct_jars,
        need_direct_targets = need_direct_targets,
        need_direct_info = need_direct_jars or need_direct_targets,
        dependency_tracking_method = "high-level",
        unused_deps_mode = unused_deps_mode,
        strict_deps_mode = strict_deps_mode,
        use_analyzer = is_strict_deps_on or is_unused_deps_on,
    )

def dependency_info_for_addons(ctx):
    return new_dependency_info(
        dependency_mode = _dependency_mode_for_addons(ctx),
        unused_deps_mode = "off",
        strict_deps_mode = get_strict_deps_mode(ctx),
        dependency_tracking_method = "high-level",
    )

def get_dependency_mode(ctx):
    if get_is_strict_deps_on(ctx):
        # all transitive dependencies are included
        return "transitive"
    elif not _is_plus_one_deps_off(ctx):
        # dependencies and dependencies of dependencies are included
        return "plus-one"
    else:
        # only explicitly-specified dependencies are included
        return "direct"

def _dependency_mode_for_addons(ctx):
    if get_is_strict_deps_on(ctx):
        return "transitive"
    else:
        return "direct"

def get_strict_deps_mode(ctx):
    if not hasattr(ctx.attr, "_dependency_analyzer_plugin"):
        return "off"

    # when the strict deps FT is removed the "default" check
    # will be removed since "default" will mean it's turned on
    if ctx.fragments.java.strict_java_deps == "default":
        return "off"
    return ctx.fragments.java.strict_java_deps

def get_is_strict_deps_on(ctx):
    return get_strict_deps_mode(ctx) != "off"

def get_unused_deps_mode(ctx):
    if ctx.attr.unused_dependency_checker_mode:
        return ctx.attr.unused_dependency_checker_mode
    else:
        return ctx.toolchains["@io_bazel_rules_scala//scala:toolchain_type"].unused_dependency_checker_mode

def _is_plus_one_deps_off(ctx):
    return ctx.toolchains["@io_bazel_rules_scala//scala:toolchain_type"].plus_one_deps_mode == "off"
