#This aspect is an example of exposing semanticdb information for each target into a json file.
# An IDE could use a json file like this to consume the semanticdb data for each target.

load("@rules_scala//scala:semanticdb_provider.bzl", "SemanticdbInfo")

def semanticdb_info_aspect_impl(target, ctx):
    if SemanticdbInfo in target:
        output_struct = struct(
            target_label = str(target.label),
            semanticdb_target_root = target[SemanticdbInfo].target_root,
            semanticdb_pluginjar = "" if target[SemanticdbInfo].plugin_jar.path == None else target[SemanticdbInfo].plugin_jar.path,
        )

        json_output_file = ctx.actions.declare_file("%s_semanticdb_info.json" % target.label.name)
        ctx.actions.write(json_output_file, json.encode_indent(output_struct))

        return [OutputGroupInfo(json_output_file = depset([json_output_file]))]
    return []

semanticdb_info_aspect = aspect(
    implementation = semanticdb_info_aspect_impl,
    attr_aspects = ["deps"],
    toolchains = ["@rules_scala//scala:toolchain_type"],
)
