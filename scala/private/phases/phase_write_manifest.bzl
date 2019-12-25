#
# PHASE: write manifest
#
# DOCUMENT THIS
#
load(
    "@io_bazel_rules_scala//scala/private:common.bzl",
    "write_manifest",
)

def phase_write_manifest(ctx, p):
    write_manifest(ctx)
