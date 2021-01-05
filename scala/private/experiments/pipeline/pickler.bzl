ScalaSigJar = provider(
    doc = "ScalaSigJar",
    fields = [
        "direct",
        "transitive",
    ],
)

def pickler(ctx):
    jar = ctx.actions.declare_file(ctx.label.name + "-sig.jar")

    # TODO: Breaks //test/src/main/scala/scalarules/test/twitter_scrooge:twodeep
    classpath_direct = depset(
        direct = [
            dep[ScalaSigJar].direct
            for dep in ctx.attr.deps
            if ScalaSigJar in dep
        ],
        transitive = [
            dep[JavaInfo].compile_jars
            for dep in ctx.attr.deps
            if not ScalaSigJar in dep
        ],
    )

    classpath_transitive = depset(
        transitive = [
            dep[ScalaSigJar].transitive if ScalaSigJar in dep else dep[JavaInfo].transitive_deps
            for dep in ctx.attr.deps
        ],
    )

    classpath = classpath_transitive

    plugins = ctx.files._pipeline_plugins + ctx.files.plugins
    plugins_opts = [
        ctx.expand_location(v, ctx.attr.plugins)
        for v in ctx.attr.scalacopts
        if v.startswith("-P:")
    ]

    sources = ctx.files.srcs

    args = ctx.actions.args()
    args.set_param_file_format("multiline")
    args.use_param_file(param_file_arg = "@%s", use_always = True)
    args.add_joined("-classpath", classpath, join_with = ctx.configuration.host_path_separator)
    args.add_all(plugins, before_each = "-Xplugin")
    args.add_all(plugins_opts)
    args.add("-P:Manifest:Manifest-Version=1.0")
    args.add("-P:Manifest:Target-Label=" + str(ctx.label))
    args.add("-YjarFactory", "pipeline.FixedTimeJarFactory")
    args.add("-usejavacp")
    args.add("-Youtline")
    args.add("-Ystop-after:pickler")
    args.add("-Ymacro-expand:none")
    args.add("-Ypickle-java")
    args.add("-Ypickle-write", jar)

    #    args.add("-Ypickle-write-api-only") # TODO: Breaks //test/jmh:test_benchmark_generator
    #    args.add("-Ylog-classpath")
    #    args.add("-verbose")
    args.add_all(sources)

    ctx.actions.run(
        executable = ctx.executable._pipeline_compiler,
        arguments = [args],
        inputs = depset(direct = sources + plugins, transitive = [classpath]),
        outputs = [jar],
        mnemonic = "ScalaPickler",
        execution_requirements = {"supports-workers": "1"},
    )

    return ScalaSigJar(
        direct = jar,
        transitive = depset(
            direct = [jar],
            transitive = [classpath],
        ),
    )

def phase_pickler(ctx, p):
    if ctx.attr.srcs:
        return struct(
            external_providers = {"ScalaSigJar": pickler(ctx)},
        )
    else:
        return struct()
