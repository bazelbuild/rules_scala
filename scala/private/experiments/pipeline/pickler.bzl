
#load(
#    "@io_bazel_rules_scala//scala/private/toolchain_deps:toolchain_deps.bzl",
#    "find_deps_info_on",
#)

ScalaSigJar = provider(
    doc = "ScalaSigJar",
    fields = [
        "direct",
        "transitive",
    ],
)

def pickler(ctx):
    jar = ctx.actions.declare_file(ctx.label.name + "-sig.jar")

    classpath = depset(
#        direct = find_deps_info_on(ctx, "@io_bazel_rules_scala//scala:toolchain_type", "scala_compile_classpath").deps,
        transitive = [
            dep[ScalaSigJar].transitive
            if ScalaSigJar in dep
            else dep[JavaInfo].transitive_deps
            for dep in ctx.attr.deps #+ find_deps_info_on(ctx, "@io_bazel_rules_scala//scala:toolchain_type", "scala_compile_classpath").deps
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
#    args.add("-Ylog-classpath")
    args.add("-Ypickle-java")
#    args.add("-Ypickle-write-api-only") # TODO: Breaks //test/jmh:test_benchmark_generator
    args.add("-Ypickle-write", jar)
    args.add_joined("-classpath", classpath, join_with = ctx.configuration.host_path_separator)
    args.add_all(ctx.files.srcs)

    ctx.actions.run(
        executable = ctx.executable._pickler,
        arguments = [args],
        inputs = depset(direct = ctx.files.srcs + ctx.files.plugins, transitive = [classpath]),
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
