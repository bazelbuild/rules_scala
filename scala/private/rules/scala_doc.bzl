"""Scaladoc support"""

load("@rules_java//java/common:java_info.bzl", "JavaInfo")
load("//scala:providers.bzl", "ScalaInfo")
load("//scala/private:common.bzl", "collect_plugin_paths")

ScaladocAspectInfo = provider(fields = [
    "src_files",  #depset[File]
    "compile_jars",  #depset[File]
    "macro_classpath",  #depset[File]
    "plugins",  #depset[Target]
])

def _scaladoc_intransitive_aspect_impl(target, ctx):
    """Build scaladocs only for the provided targets."""
    return _scaladoc_aspect_impl(target, ctx, transitive = False)

def _scaladoc_aspect_impl(target, ctx, transitive = True):
    """Collect source files and compile_jars from JavaInfo-returning deps."""

    src_files = depset()
    plugins = depset()
    compile_jars = depset()

    # We really only care about visited targets with srcs, so only look at those.
    if hasattr(ctx.rule.attr, "srcs"):
        # Collect only Java and Scala sources enumerated in visited targets, including src_files in deps.
        src_files = depset([file for file in ctx.rule.files.srcs if file.extension.lower() in ["java", "scala"]])

        compile_jars = target[JavaInfo].transitive_compile_time_jars

        if hasattr(ctx.rule.attr, "plugins"):
            plugins = depset(ctx.rule.attr.plugins)

    macro_classpath = []

    for dependency in getattr(ctx.rule.attr, "deps", []):
        if ScalaInfo in dependency and dependency[ScalaInfo].contains_macros:
            macro_classpath.append(dependency[JavaInfo].transitive_runtime_jars)

    # Sometimes we only want to generate scaladocs for a single target and not all of its
    # dependencies
    transitive_srcs = depset()
    transitive_plugins = depset()

    if transitive:
        for dep in ctx.rule.attr.deps:
            if ScaladocAspectInfo in dep:
                aspec_info = dep[ScaladocAspectInfo]
                transitive_srcs = aspec_info.src_files
                transitive_plugins = aspec_info.plugins

    return [ScaladocAspectInfo(
        src_files = depset(transitive = [src_files, transitive_srcs]),
        compile_jars = depset(transitive = [compile_jars]),
        macro_classpath = depset(transitive = macro_classpath),
        plugins = depset(transitive = [plugins, transitive_plugins]),
    )]

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
    src_files = depset(transitive = [dep[ScaladocAspectInfo].src_files for dep in ctx.attr.deps])
    compile_jars = depset(transitive = [dep[ScaladocAspectInfo].compile_jars for dep in ctx.attr.deps])

    # See the documentation for `collect_jars` in `scala/private/common.bzl` to understand why this is prepended to the
    # classpath
    macro_classpath = depset(transitive = [dep[ScaladocAspectInfo].macro_classpath for dep in ctx.attr.deps])

    # Get the 'real' paths to the plugin jars.
    plugins = collect_plugin_paths(depset(transitive = [dep[ScaladocAspectInfo].plugins for dep in ctx.attr.deps]).to_list())

    # Construct the full classpath depset since we need to add compiler plugins too.
    classpath = depset(transitive = [macro_classpath, plugins, compile_jars])

    # Construct scaladoc args, which also include scalac args.
    # See `scaladoc -help` for more information.
    args = ctx.actions.args()
    args.set_param_file_format("multiline")
    args.use_param_file(param_file_arg = "@%s", use_always = True)
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
                default = "//src/scala/io/bazel/rules_scala/scaladoc_support:scaladoc_generator",
            ),
        },
        doc = "Generate Scaladoc HTML documentation for source files in from the given dependencies.",
        implementation = _scala_doc_impl,
    )
