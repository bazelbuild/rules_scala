"""Scaladoc support"""

load("@io_bazel_rules_scala//scala/private:common.bzl", "collect_plugin_paths")

ScaladocAspectInfo = provider(fields = [
    "src_files",
    "compile_jars",
    "plugins",
])

def _scaladoc_aspect_impl(target, ctx):
    """Collect source files and compile_jars from JavaInfo-returning deps."""

    # We really only care about visited targets with srcs, so only look at those.
    if hasattr(ctx.rule.attr, "srcs"):
        # Collect only Java and Scala sources enumerated in visited targets.
        src_files = depset(direct = [file for file in ctx.rule.files.srcs if file.extension.lower() in ["java", "scala"]])

        # Collect compile_jars from visited targets' deps.
        compile_jars = depset(transitive = [dep[JavaInfo].compile_jars for dep in ctx.rule.attr.deps if JavaInfo in dep])

        plugins = depset()
        if hasattr(ctx.rule.attr, "plugins"):
            plugins = depset(direct = ctx.rule.attr.plugins)

        return [ScaladocAspectInfo(
            src_files = src_files,
            compile_jars = compile_jars,
            plugins = plugins,
        )]
    else:
        return []

scaladoc_aspect = aspect(
    implementation = _scaladoc_aspect_impl,
    attr_aspects = ["deps"],
    required_aspect_providers = [
        [JavaInfo],
    ],
)

def _scala_doc_impl(ctx):
    # scaladoc warns if you don't have the output directory already created, which is annoying.
    output_path = ctx.actions.declare_directory("{}.html".format(ctx.attr.name))

    # Collect all source files and compile_jars to pass to scaladoc by way of an aspect.
    src_files = depset(transitive = [dep[ScaladocAspectInfo].src_files for dep in ctx.attr.deps])
    compile_jars = depset(transitive = [dep[ScaladocAspectInfo].compile_jars for dep in ctx.attr.deps])

    # Get the 'real' paths to the plugin jars.
    plugins = collect_plugin_paths(depset(transitive = [dep[ScaladocAspectInfo].plugins for dep in ctx.attr.deps]))

    # Construct the full classpath depset since we need to add compiler plugins too.
    classpath = depset(transitive = [plugins, compile_jars])

    # Construct scaladoc args, which also include scalac args.
    # See `scaladoc -help` for more information.
    args = ctx.actions.args()
    args.add("-usejavacp")
    args.add("-d", output_path.path)
    args.add_all(plugins, format_each = "-Xplugin:%s")
    args.add_joined("-classpath", classpath, join_with = ":")
    args.add_all(src_files)

    # Run the scaladoc tool!
    ctx.actions.run(
        inputs = depset(transitive = [src_files, classpath]),
        outputs = [output_path],
        executable = ctx.attr._scaladoc.files_to_run.executable,
        mnemonic = "ScalaDoc",
        progress_message = "scaladoc {}".format(ctx.label),
        arguments = [args],
    )

    return [DefaultInfo(files = depset(direct = [output_path]))]

scala_doc = rule(
    attrs = {
        "deps": attr.label_list(
            aspects = [scaladoc_aspect],
            providers = [JavaInfo],
        ),
        "_scaladoc": attr.label(
            cfg = "host",
            executable = True,
            default = Label("//src/scala/io/bazel/rules_scala/scaladoc_support:scaladoc_generator"),
        ),
    },
    doc = "Generate Scaladoc HTML documentation for source files in from the given dependencies.",
    implementation = _scala_doc_impl,
)
