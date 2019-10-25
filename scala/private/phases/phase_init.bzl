#
# PHASE: init
#
# DOCUMENT THIS
#
load(
    "@io_bazel_rules_scala//scala/private:rule_impls.bzl",
    "get_scalac_provider",
)
load(
    "@io_bazel_rules_scala//scala/private:common.bzl",
    "collect_jars",
    "collect_srcjars",
    "write_manifest",
)

def phase_library_init(ctx, p):
    # This will be used to pick up srcjars from non-scala library
    # targets (like thrift code generation)
    srcjars = collect_srcjars(ctx.attr.deps)

    # Add information from exports (is key that AFTER all build actions/runfiles analysis)
    # Since after, will not show up in deploy_jar or old jars runfiles
    # Notice that compile_jars is intentionally transitive for exports
    exports_jars = collect_jars(ctx.attr.exports)

    args = phase_common_init(ctx, p)

    return struct(
        srcjars = srcjars,
        exports_jars = exports_jars,
        scalac_provider = args.scalac_provider,
    )

def phase_common_init(ctx, p):
    write_manifest(ctx)
    return struct(
        scalac_provider = get_scalac_provider(ctx),
    )
