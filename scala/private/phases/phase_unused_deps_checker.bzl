#
# PHASE: unused deps checker
#
# DOCUMENT THIS
#
load(
    "@io_bazel_rules_scala//scala/private:rule_impls.bzl",
    "get_unused_dependency_checker_mode",
)

def phase_unused_deps_checker(ctx, p):
    return get_unused_dependency_checker_mode(ctx)
