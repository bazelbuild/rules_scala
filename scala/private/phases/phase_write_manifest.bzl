#
# PHASE: write manifest
#
# DOCUMENT THIS
#
load(
    "@io_bazel_rules_scala//scala/private:common.bzl",
    _write_manifest_file = "write_manifest_file",
)

def phase_write_manifest(ctx, p):
    main_class = getattr(ctx.attr, "main_class", None)
    _write_manifest_file(ctx.actions, ctx.outputs.manifest, main_class)
