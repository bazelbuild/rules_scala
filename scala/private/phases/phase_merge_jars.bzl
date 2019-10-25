#
# PHASE: merge jars
#
# DOCUMENT THIS
#
load(
    "@io_bazel_rules_scala//scala/private:rule_impls.bzl",
    "merge_jars",
)

def phase_merge_jars(ctx, p):
    merge_jars(
        actions = ctx.actions,
        deploy_jar = ctx.outputs.deploy_jar,
        singlejar_executable = ctx.executable._singlejar,
        jars_list = p.compile.rjars.to_list(),
        main_class = getattr(ctx.attr, "main_class", ""),
        progress_message = "Merging Scala jar: %s" % ctx.label,
    )
