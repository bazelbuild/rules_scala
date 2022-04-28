#
# PHASE: compile
#
# DOCUMENT THIS
#
load("@bazel_tools//tools/jdk:toolchain_utils.bzl", "find_java_toolchain")
load(
    "@io_bazel_rules_scala//scala/private:paths.bzl",
    _get_files_with_extension = "get_files_with_extension",
    _java_extension = "java_extension",
    _scala_extension = "scala_extension",
    _srcjar_extension = "srcjar_extension",
)
load(
    "@io_bazel_rules_scala//scala/private:rule_impls.bzl",
    _compile_java = "compile_java",
    _compile_scala = "compile_scala",
)
load(":resources.bzl", _resource_paths = "paths")
load("@io_bazel_rules_scala_config//:config.bzl", "SCALA_VERSION")

buildijar_default_value = True if SCALA_VERSION.startswith("2.") else False

def phase_compile_binary(ctx, p):
    args = struct(
        buildijar = False,
        unused_dependency_checker_ignored_targets = [
            target.label
            for target in p.scalac_provider.default_classpath +
                          ctx.attr.unused_dependency_checker_ignored_targets
        ],
    )
    return _phase_compile_default(ctx, p, args)

def phase_compile_library(ctx, p):
    args = struct(
        srcjars = p.collect_srcjars,
        unused_dependency_checker_ignored_targets = [
            target.label
            for target in p.scalac_provider.default_classpath + ctx.attr.exports +
                          ctx.attr.unused_dependency_checker_ignored_targets
        ],
    )
    return _phase_compile_default(ctx, p, args)

def phase_compile_library_for_plugin_bootstrapping(ctx, p):
    args = struct(
        buildijar = ctx.attr.build_ijar,
    )
    return _phase_compile_default(ctx, p, args)

def phase_compile_macro_library(ctx, p):
    args = struct(
        buildijar = False,
        unused_dependency_checker_ignored_targets = [
            target.label
            for target in p.scalac_provider.default_macro_classpath + ctx.attr.exports +
                          ctx.attr.unused_dependency_checker_ignored_targets
        ],
    )
    return _phase_compile_default(ctx, p, args)

def phase_compile_junit_test(ctx, p):
    args = struct(
        buildijar = False,
        implicit_junit_deps_needed_for_java_compilation = [
            ctx.attr._junit_classpath,
        ],
        unused_dependency_checker_ignored_targets = [
            target.label
            for target in p.scalac_provider.default_classpath +
                          ctx.attr.unused_dependency_checker_ignored_targets
        ] + [
            ctx.attr._junit_classpath.label,
            ctx.attr.suite_label.label,
            ctx.attr._bazel_test_runner.label,
        ],
    )
    return _phase_compile_default(ctx, p, args)

def phase_compile_repl(ctx, p):
    args = struct(
        buildijar = False,
        unused_dependency_checker_ignored_targets = [
            target.label
            for target in p.scalac_provider.default_repl_classpath +
                          ctx.attr.unused_dependency_checker_ignored_targets
        ],
    )
    return _phase_compile_default(ctx, p, args)

def phase_compile_scalatest(ctx, p):
    args = struct(
        buildijar = False,
        unused_dependency_checker_ignored_targets = [
            target.label
            for target in p.scalac_provider.default_classpath +
                          [ctx.attr._scalatest] +
                          ctx.attr.unused_dependency_checker_ignored_targets
        ],
    )
    return _phase_compile_default(ctx, p, args)

def phase_compile_common(ctx, p):
    return _phase_compile_default(ctx, p)

def _phase_compile_default(ctx, p, _args = struct()):
    return _phase_compile(
        ctx,
        p,
        _args.srcjars if hasattr(_args, "srcjars") else depset(),
        _args.buildijar if hasattr(_args, "buildijar") else buildijar_default_value,
        _args.implicit_junit_deps_needed_for_java_compilation if hasattr(_args, "implicit_junit_deps_needed_for_java_compilation") else [],
        unused_dependency_checker_ignored_targets = _args.unused_dependency_checker_ignored_targets if hasattr(_args, "unused_dependency_checker_ignored_targets") else [],
    )

def _phase_compile(
        ctx,
        p,
        srcjars,
        buildijar,
        # TODO: generalize this hack
        implicit_junit_deps_needed_for_java_compilation,
        unused_dependency_checker_ignored_targets):
    manifest = ctx.outputs.manifest
    jars = p.collect_jars.compile_jars
    rjars = p.collect_jars.transitive_runtime_jars
    transitive_compile_jars = p.collect_jars.transitive_compile_jars
    jars2labels = p.collect_jars.jars2labels.jars_to_labels
    deps_providers = p.collect_jars.deps_providers
    default_classpath = p.scalac_provider.default_classpath

    out = _compile_or_empty(
        ctx,
        manifest,
        jars,
        srcjars,
        buildijar,
        transitive_compile_jars,
        jars2labels,
        implicit_junit_deps_needed_for_java_compilation,
        p.dependency,
        deps_providers,
        default_classpath,
        unused_dependency_checker_ignored_targets,
    )

    # TODO: simplify the return values and use provider
    return struct(
        files = depset(out.full_jars),
        rjars = depset(out.full_jars, transitive = [rjars]),
        merged_provider = out.merged_provider,
        external_providers = {
            "JavaInfo": out.merged_provider,
        },
    )

def _compile_or_empty(
        ctx,
        manifest,
        jars,
        srcjars,
        buildijar,
        transitive_compile_jars,
        jars2labels,
        implicit_junit_deps_needed_for_java_compilation,
        dependency_info,
        deps_providers,
        default_classpath,
        unused_dependency_checker_ignored_targets):
    # We assume that if a srcjar is present, it is not empty
    if len(ctx.files.srcs) + len(srcjars.to_list()) == 0:
        _build_nosrc_jar(ctx)

        scala_compilation_provider = _create_scala_compilation_provider(ctx, ctx.outputs.jar, None, deps_providers)

        #  no need to build ijar when empty
        return struct(
            full_jars = [ctx.outputs.jar],
            merged_provider = scala_compilation_provider,
        )
    else:
        java_srcs = _get_files_with_extension(ctx, _java_extension)
        scala_srcs = _get_files_with_extension(ctx, _scala_extension)
        in_srcjars = _get_files_with_extension(ctx, _srcjar_extension)
        all_srcjars = depset(in_srcjars, transitive = [srcjars])

        sources = scala_srcs + java_srcs
        _compile_scala(
            ctx,
            ctx.label,
            ctx.outputs.jar,
            manifest,
            ctx.outputs.statsfile,
            ctx.outputs.diagnosticsfile,
            sources,
            jars,
            all_srcjars,
            transitive_compile_jars,
            ctx.attr.plugins,
            ctx.attr.resource_strip_prefix,
            ctx.files.resources,
            ctx.files.resource_jars,
            jars2labels,
            ctx.attr.scalacopts,
            ctx.attr.print_compile_time,
            ctx.attr.expect_java_output,
            ctx.attr.scalac_jvm_flags,
            ctx.executable._scalac,
            dependency_info,
            unused_dependency_checker_ignored_targets,
        )

        # build ijar if needed
        if buildijar:
            ijar = java_common.run_ijar(
                ctx.actions,
                jar = ctx.outputs.jar,
                target_label = ctx.label,
                java_toolchain = find_java_toolchain(ctx, ctx.attr._java_toolchain),
            )
        else:
            #  macro code needs to be available at compile-time,
            #  so set ijar == jar
            ijar = ctx.outputs.jar

        source_jar = _pack_source_jar(ctx, scala_srcs, in_srcjars)
        scala_compilation_provider = _create_scala_compilation_provider(ctx, ijar, source_jar, deps_providers)

        # compile the java now
        java_jar = _try_to_compile_java_jar(
            ctx,
            ijar,
            all_srcjars,
            java_srcs,
            implicit_junit_deps_needed_for_java_compilation,
            default_classpath,
        )

        full_jars = [ctx.outputs.jar]
        if java_jar:
            full_jars.append(java_jar.jar)

        if java_jar:
            merged_provider = java_common.merge([scala_compilation_provider, java_jar.java_compilation_provider])
        else:
            merged_provider = scala_compilation_provider

        return struct(
            full_jars = full_jars,
            merged_provider = merged_provider,
        )

def _build_nosrc_jar(ctx):
    resources = _add_resources_cmd(ctx)
    ijar_cmd = ""

    # this ensures the file is not empty
    resources += "META-INF/MANIFEST.MF=%s\n" % ctx.outputs.manifest.path

    zipper_arg_path = ctx.actions.declare_file("%s_zipper_args" % ctx.label.name)
    ctx.actions.write(zipper_arg_path, resources)
    cmd = """
set -o errexit
set -o nounset
set -o pipefail
rm -f {jar_output}
{zipper} c {jar_output} @{path}
# ensures that empty src targets still emit a statsfile and a diagnosticsfile
touch {statsfile}
touch {diagnosticsfile}
""" + ijar_cmd

    cmd = cmd.format(
        path = zipper_arg_path.path,
        jar_output = ctx.outputs.jar.path,
        zipper = ctx.executable._zipper.path,
        statsfile = ctx.outputs.statsfile.path,
        diagnosticsfile = ctx.outputs.diagnosticsfile.path,
    )

    outs = [ctx.outputs.jar, ctx.outputs.statsfile, ctx.outputs.diagnosticsfile]
    inputs = ctx.files.resources + [ctx.outputs.manifest]

    ctx.actions.run_shell(
        inputs = inputs,
        tools = [ctx.executable._zipper, zipper_arg_path],
        outputs = outs,
        command = cmd,
        progress_message = "scala %s" % ctx.label,
        arguments = [],
    )

def _create_scala_compilation_provider(ctx, ijar, source_jar, deps_providers):
    exports = []
    if hasattr(ctx.attr, "exports"):
        exports = [dep[JavaInfo] for dep in ctx.attr.exports]
    runtime_deps = []
    if hasattr(ctx.attr, "runtime_deps"):
        runtime_deps = [dep[JavaInfo] for dep in ctx.attr.runtime_deps]
    return JavaInfo(
        output_jar = ctx.outputs.jar,
        compile_jar = ijar,
        source_jar = source_jar,
        deps = deps_providers,
        exports = exports,
        runtime_deps = runtime_deps,
        neverlink = ctx.attr.neverlink,
    )

def _pack_source_jar(ctx, scala_srcs, input_srcjars):
    # https://github.com/bazelbuild/bazel/blob/ff6c0333e4f957bb9f7ab5401b01dbf3e9b515b1/src/main/java/com/google/devtools/build/lib/rules/java/JavaInfoBuildHelper.java#L180-L183
    # java_common.pack_sources checks for no srcs and only a single input jar
    # if so, it checks that output_source_jar is null
    # passing that, it will return the input source jar directly
    # However, pack_sources will FAIL if both output_source_jar and
    # the deprecated output_jar field are BOTH null
    # Therefore, we can return the single input jar ourselves
    if not scala_srcs and len(input_srcjars) == 1:
        return input_srcjars[0]
    else:
        output_jar = ctx.outputs.jar
        without_ext = output_jar.basename
        if output_jar.extension:
            ext_len = len("." + output_jar.extension)
            without_ext = output_jar.basename[:-ext_len]
        source_jar_name = without_ext + "-src.jar"

        output_source_jar = ctx.actions.declare_file(source_jar_name, sibling = output_jar)

        return java_common.pack_sources(
            ctx.actions,
            output_source_jar = output_source_jar,
            sources = scala_srcs,
            source_jars = input_srcjars,
            java_toolchain = find_java_toolchain(ctx, ctx.attr._java_toolchain),
        )

def _try_to_compile_java_jar(
        ctx,
        scala_output,
        all_srcjars,
        java_srcs,
        implicit_junit_deps_needed_for_java_compilation,
        default_classpath):
    if not java_srcs and (not (all_srcjars and ctx.attr.expect_java_output)):
        return False

    providers_of_dependencies = _collect_java_providers_of(ctx.attr.deps)
    providers_of_dependencies += _collect_java_providers_of(
        implicit_junit_deps_needed_for_java_compilation,
    )
    providers_of_dependencies += _collect_java_providers_of(
        default_classpath,
    )
    scala_sources_java_provider = _interim_java_provider_for_java_compilation(
        scala_output,
    )
    providers_of_dependencies.append(scala_sources_java_provider)

    full_java_jar = ctx.actions.declare_file(ctx.label.name + "_java.jar")

    provider = _compile_java(
        ctx,
        source_jars = all_srcjars.to_list(),
        source_files = java_srcs,
        output = full_java_jar,
        extra_javac_opts = ctx.attr.javacopts + ctx.attr.javac_jvm_flags,
        providers_of_dependencies = providers_of_dependencies,
    )

    return struct(
        ijar = provider.compile_jars.to_list().pop(),
        jar = full_java_jar,
        source_jars = provider.source_jars,
        java_compilation_provider = provider,
    )

def _add_resources_cmd(ctx):
    paths = _resource_paths(ctx.files.resources, ctx.attr.resource_strip_prefix)
    lines = ["{target}={source}\n".format(target = p[0], source = p[1]) for p in paths]
    return "".join(lines)

def _collect_java_providers_of(deps):
    providers = []
    for dep in deps:
        if JavaInfo in dep:
            providers.append(dep[JavaInfo])
    return providers

def _interim_java_provider_for_java_compilation(scala_output):
    return JavaInfo(
        output_jar = scala_output,
        compile_jar = scala_output,
        neverlink = True,
    )
