#
# PHASE: unused deps checker
#
# DOCUMENT THIS
#

def phase_unused_deps_checker(ctx, p):
    if ctx.attr.unused_dependency_checker_mode:
        return ctx.attr.unused_dependency_checker_mode
    else:
        return ctx.toolchains["@io_bazel_rules_scala//scala:toolchain_type"].scalainfo.unused_dependency_checker_mode
