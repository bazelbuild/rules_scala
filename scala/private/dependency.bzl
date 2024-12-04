# This file contains all computations for what the dependency mode is
# (i.e. transitive, plus-one, direct, etc)
# and what/how dependency analysis is performed (unused deps, strict deps, etc).

def new_dependency_info(
        dependency_mode,
        unused_deps_mode,
        strict_deps_mode,
        compiler_deps_mode,
        dependency_tracking_method):
    is_strict_deps_on = strict_deps_mode != "off"
    is_unused_deps_on = unused_deps_mode != "off"

    return struct(
        dependency_mode = dependency_mode,
        need_indirect_info = is_strict_deps_on,
        need_direct_info = is_strict_deps_on or is_unused_deps_on,
        dependency_tracking_method = dependency_tracking_method,
        unused_deps_mode = unused_deps_mode,
        strict_deps_mode = strict_deps_mode,
        compiler_deps_mode = compiler_deps_mode,
        use_analyzer = is_strict_deps_on or is_unused_deps_on,
    )

# TODO(https://github.com/bazelbuild/rules_scala/issues/987): Clariy the situation
def legacy_unclear_dependency_info_for_protobuf_scrooge(ctx):
    return new_dependency_info(
        dependency_mode = _legacy_unclear_dependency_mode_for_protobuf_scrooge(ctx),
        unused_deps_mode = "off",
        strict_deps_mode = get_strict_deps_mode(ctx),
        compiler_deps_mode = get_compiler_deps_mode(ctx),
        dependency_tracking_method = "high-level",
    )

# TODO(https://github.com/bazelbuild/rules_scala/issues/987): Clariy the situation
def _legacy_unclear_dependency_mode_for_protobuf_scrooge(ctx):
    if _is_strict_deps_on(ctx):
        return "transitive"
    else:
        return "direct"

def get_strict_deps_mode(ctx):
    if not hasattr(ctx.attr, "_dependency_analyzer_plugin"):
        return "off"

    return ctx.toolchains[Label("//scala:toolchain_type")].strict_deps_mode

def get_compiler_deps_mode(ctx):
    if not hasattr(ctx.attr, "_dependency_analyzer_plugin"):
        return "off"

    return ctx.toolchains[Label("//scala:toolchain_type")].compiler_deps_mode

def _is_strict_deps_on(ctx):
    return get_strict_deps_mode(ctx) != "off"
