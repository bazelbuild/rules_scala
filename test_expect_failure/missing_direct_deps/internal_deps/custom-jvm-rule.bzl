def _custom_jvm_impl(ctx):
    print(ctx.label)
    transitive_compile_jars = _collect(ctx.attr.deps)
    providers = [JavaInfo(output_jar = jar, compile_jar = jar) for jar in transitive_compile_jars]
    return [java_common.merge(providers)]

def _collect(deps):
    transitive_compile_jars = depset()
    for dep_target in deps:
        transitive_compile_jars += dep_target[JavaInfo].transitive_compile_time_jars
    return transitive_compile_jars

custom_jvm = rule(
    implementation = _custom_jvm_impl,
    attrs = {
        "deps": attr.label_list(),
    },
)
