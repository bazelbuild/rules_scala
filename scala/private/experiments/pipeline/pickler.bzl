
ScalaSigJar = provider(
    doc = "ScalaSigJar",
    fields = [
        "direct",
        "transitive",
    ],
)

def pickler(ctx):
    jar = ctx.actions.declare_file(ctx.label.name + "-sig.jar")

    classpath = depset(transitive = [
        dep[ScalaSigJar].transitive
        if ScalaSigJar in dep
        else
        dep[JavaInfo].transitive_deps
        for dep in ctx.attr.deps
    ])

    plugins = ctx.files.plugins
    plugins_opts = [
        ctx.expand_location(v, ctx.attr.plugins)
        for v in ctx.attr.scalacopts
        if v.startswith("-P:")
    ]

    args = ctx.actions.args()
    args.set_param_file_format("multiline")
    args.use_param_file(param_file_arg = "@%s", use_always = True)
    args.add_all(plugins, before_each = "-Xplugin")
    args.add_all(plugins_opts)
    args.add("-Youtline")
    args.add("-Ystop-after:pickler")
    args.add("-Ymacro-expand:none")
    args.add("-usejavacp")
    args.add("-YjarFactory", "pipeline.FixedTimeJarFactory")
    args.add("-Ypickle-write-api-only")
    args.add("-Ypickle-java")
    args.add("-Ypickle-write", jar)
    args.add_joined("-classpath", classpath, join_with = ctx.configuration.host_path_separator)
    args.add_all(ctx.files.srcs)

    ctx.actions.run(
        executable = ctx.executable._pickler,
        arguments = [args],
        outputs = [jar],
        mnemonic = "ScalaPickler",
        execution_requirements = {"supports-workers": "1"},
    )

    return ScalaSigJar(
        direct = jar,
        transitive = depset(
            direct = [jar], 
            transitive = [classpath]
        )
    )
