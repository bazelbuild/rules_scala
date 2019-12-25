#
# PHASE: scalac provider
#
# DOCUMENT THIS
#
load(
    "@io_bazel_rules_scala//scala/private:rule_impls.bzl",
    "get_scalac_provider",
)

def phase_scalac_provider(ctx, p):
    return get_scalac_provider(ctx)
