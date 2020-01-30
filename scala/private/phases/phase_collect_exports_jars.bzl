#
# PHASE: collect exports jars
#
# DOCUMENT THIS
#
load(
    "@io_bazel_rules_scala//scala/private:common.bzl",
    "collect_jars",
)

def phase_collect_exports_jars(ctx, p):
    # Add information from exports (is key that AFTER all build actions/runfiles analysis)
    # Since after, will not show up in deploy_jar or old jars runfiles
    # Notice that compile_jars is intentionally transitive for exports
    return collect_jars(
        dep_targets = ctx.attr.exports,
        dependency_mode = "direct",
        need_direct_info = False,
        need_indirect_info = False,
    )
