"""Scaladoc support"""

load("@io_bazel_rules_scala//scala/private:common.bzl", "collect_plugin_paths")

_ScaladocAspectInfo = provider(fields = [
    "src_files",
    "compile_jars",
    "plugins",
])

def _scaladoc_intransitive_aspect_impl(target, ctx):
    """Build scaladocs only for the provided targets."""
    return _scaladoc_aspect_impl(target, ctx, transitive = False)

def _scaladoc_aspect_impl(target, ctx, transitive = True):
    """Collect source files and compile_jars from JavaInfo-returning deps."""

    # We really only care about visited targets with srcs, so only look at those.
    if hasattr(ctx.rule.attr, "srcs"):
        # Collect only Java and Scala sources enumerated in visited targets, including src_files in deps.
        direct_deps = [file for file in ctx.rule.files.srcs if file.extension.lower() in ["java", "scala"]]

        # Sometimes we only want to generate scaladocs for a single target and not all of its
        # dependencies
        if transitive:
            transitive_deps = [dep[_ScaladocAspectInfo].src_files for dep in ctx.rule.attr.deps if _ScaladocAspectInfo in dep]
        else:
            transitive_deps = []

        src_files = depset(direct = direct_deps, transitive = transitive_deps)

        # Collect compile_jars from visited targets' deps.
        compile_jars = depset(
            direct = [file for file in ctx.rule.files.deps],
            transitive = (
                [dep[JavaInfo].compile_jars for dep in ctx.rule.attr.deps if JavaInfo in dep] +
                [dep[_ScaladocAspectInfo].compile_jars for dep in ctx.rule.attr.deps if _ScaladocAspectInfo in dep]
            ),
        )

        plugins = depset()
        if hasattr(ctx.rule.attr, "plugins"):
            plugins = depset(direct = ctx.rule.attr.plugins)

        return [_ScaladocAspectInfo(
            src_files = src_files,
            compile_jars = compile_jars,
            plugins = plugins,
        )]
    else:
        return []

_scaladoc_transitive_aspect = aspect(
    implementation = _scaladoc_aspect_impl,
    attr_aspects = ["deps"],
    required_aspect_providers = [
        [JavaInfo],
    ],
)

scaladoc_intransitive_aspect = aspect(
    implementation = _scaladoc_intransitive_aspect_impl,
    attr_aspects = ["deps"],
    required_aspect_providers = [
        [JavaInfo],
    ],
)

def _scala_doc_impl(ctx):
    # scaladoc warns if you don't have the output directory already created, which is annoying.
    output_path = ctx.actions.declare_directory("{}.html".format(ctx.attr.name))

    # Collect all source files and compile_jars to pass to scaladoc by way of an aspect.
    src_files = depset(transitive = [dep[_ScaladocAspectInfo].src_files for dep in ctx.attr.deps])
    compile_jars = depset(transitive = [dep[_ScaladocAspectInfo].compile_jars for dep in ctx.attr.deps])

    # Get the 'real' paths to the plugin jars.
    plugins = collect_plugin_paths(depset(transitive = [dep[_ScaladocAspectInfo].plugins for dep in ctx.attr.deps]).to_list())

    # Construct the full classpath depset since we need to add compiler plugins too.
    classpath = depset(transitive = [plugins, compile_jars])

    # Construct scaladoc args, which also include scalac args.
    # See `scaladoc -help` for more information.
    args = ctx.actions.args()
    args.add("-usejavacp")
    args.add("-nowarn")  # turn off warnings for now since they can obscure actual errors for large scala_doc targets
    args.add_all(ctx.attr.scalacopts)
    args.add("-d", output_path.path)
    args.add_all(plugins, format_each = "-Xplugin:%s")
    args.add_joined("-classpath", classpath, join_with = ctx.configuration.host_path_separator)
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

def make_scala_doc_rule(aspect = _scaladoc_transitive_aspect):
    return rule(
        attrs = {
            "deps": attr.label_list(
                aspects = [aspect],
                providers = [JavaInfo],
            ),
            "scalacopts": attr.string_list(),
            "_scaladoc": attr.label(
                cfg = "exec",
                executable = True,
                default = Label("//src/scala/io/bazel/rules_scala/scaladoc_support:scaladoc_generator"),
            ),
        },
        doc = "Generate Scaladoc HTML documentation for source files in from the given dependencies.",
        implementation = _scala_doc_impl,
    )
