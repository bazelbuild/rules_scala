def _mix_java_scala_lib_impl(ctx):
    paths = [f.path for f in ctx.files.deps]
    for path in paths:
        print(path)

mix_java_scala_lib_rule = rule(
    implementation = _mix_java_scala_lib_impl,
    attrs = {
        "deps": attr.label_list(),
    }
)
