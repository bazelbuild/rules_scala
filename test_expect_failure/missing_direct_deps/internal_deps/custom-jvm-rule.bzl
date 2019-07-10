#This rule is an example for a jvm rule that doesn't support Jars2Labels
def _custom_jvm_impl(ctx):   
    jar = ctx.file.main
    provider = JavaInfo(output_jar = jar,
             compile_jar = jar,
             deps = [target[JavaInfo] for target in ctx.attr.deps]
    )]
    return [provider]

custom_jvm = rule(
    implementation = _custom_jvm_impl,
    attrs = {
        "main": attr.label(allow_single_file = True), #just used so we'll be able to build the JavaInfo with a "main" jar
        "deps": attr.label_list(),
    },
)
