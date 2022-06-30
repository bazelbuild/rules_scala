#
# PHASE: declare executable
#
# DOCUMENT THIS
#
load(
    "@io_bazel_rules_scala//scala/private:rule_impls.bzl",
    "is_windows",
)

def phase_declare_executable(ctx, p):
    if (is_windows(ctx)):
        return struct(
            executable = ctx.actions.declare_file("%s.exe" % ctx.label.name),
        )
    else:
        return struct(
            executable = ctx.actions.declare_file("%s.sh" % ctx.label.name),
        )
