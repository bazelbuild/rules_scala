#
# PHASE: declare executable
#
# DOCUMENT THIS
#
load("//scala/private:rule_impls.bzl", "is_windows")

def phase_declare_executable(ctx, p):
    if (is_windows(ctx)):
        return struct(
            executable = ctx.actions.declare_file("%s.exe" % ctx.label.name),
        )
    else:
        return struct(
            executable = ctx.actions.declare_file(ctx.label.name),
        )
