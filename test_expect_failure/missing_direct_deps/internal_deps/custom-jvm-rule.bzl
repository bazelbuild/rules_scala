#This rule is an example for a jvm rule that doesn't support Jars2Labels
def _custom_jvm_impl(ctx):
    # TODO(#8867): Migrate away from the placeholder jar hack when #8867 is fixed.
    jar = ctx.file.jar
    provider = JavaInfo(
        output_jar = jar,
        compile_jar = jar,
        deps = [target[JavaInfo] for target in ctx.attr.deps],
    )
    return [provider]

custom_jvm = rule(
    implementation = _custom_jvm_impl,
    attrs = {
        "deps": attr.label_list(),
        "jar": attr.label(
            allow_single_file = True,
            default = Label("@io_bazel_rules_scala//scala:libPlaceHolderClassToCreateEmptyJarForScalaImport.jar"),
        ),
    },
)
