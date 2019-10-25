#
# PHASE: declare executable
#
# DOCUMENT THIS
#
load(
    "@io_bazel_rules_scala//scala/private:rule_impls.bzl",
    "declare_executable",
)

def phase_declare_executable(ctx, p):
    return declare_executable(ctx)
