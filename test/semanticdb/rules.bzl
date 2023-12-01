load("//scala:semanticdb_provider.bzl", "SemanticdbInfo")

def semanticdb_vars_script_impl(ctx):
    if SemanticdbInfo in ctx.attr.dep:
        out_script = ctx.actions.declare_file("%s.sh" % ctx.label.name)
        semanticdb_info = ctx.attr.dep[SemanticdbInfo]

        ctx.actions.expand_template(
            output = out_script,
            template = ctx.file._script,
            substitutions = {
                "%TARGETROOT%": "" if semanticdb_info.target_root == None else semanticdb_info.target_root,
                "%ENABLED%": "1" if semanticdb_info.semanticdb_enabled else "0",
                "%ISBUNDLED%": "1" if semanticdb_info.is_bundled_in_jar else "0",
                "%PLUGINPATH%": "" if semanticdb_info.plugin_jar == None else semanticdb_info.plugin_jar.path,
            },
        )
        return [
            DefaultInfo(files = depset(
                [out_script],
                transitive = [ctx.attr.dep[DefaultInfo].files],
            )),
        ]
    return None

semanticdb_vars_script = rule(
    implementation = semanticdb_vars_script_impl,
    attrs = {
        "dep": attr.label(mandatory = True),
        "_script": attr.label(
            allow_single_file = True,
            default = "semantic_provider_vars.sh.template",
        ),
    },
)
