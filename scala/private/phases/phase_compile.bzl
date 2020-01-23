#
# PHASE: compile
#
# DOCUMENT THIS
#
load("@bazel_skylib//lib:paths.bzl", _paths = "paths")
load("@bazel_tools//tools/jdk:toolchain_utils.bzl", "find_java_runtime_toolchain", "find_java_toolchain")
load(
    "@io_bazel_rules_scala//scala/private:coverage_replacements_provider.bzl",
    _coverage_replacements_provider = "coverage_replacements_provider",
)
load(
    "@io_bazel_rules_scala//scala/private:rule_impls.bzl",
    _adjust_resources_path_by_default_prefixes = "adjust_resources_path_by_default_prefixes",
    _compile_scala = "compile_scala",
    _expand_location = "expand_location",
)

_java_extension = ".java"

_scala_extension = ".scala"

_srcjar_extension = ".srcjar"

_empty_coverage_struct = struct(
    instrumented_files = None,
    providers = [],
    replacements = {},
)

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
        unused_dependency_checker_ignored_targets = [
            target.label
            for target in p.scalac_provider.default_classpath + ctx.attr.exports
        ],
        unused_dependency_checker_mode = "off",
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
            ctx.attr._junit,
            ctx.attr._hamcrest,
        ],
        unused_dependency_checker_ignored_targets = [
            target.label
            for target in p.scalac_provider.default_classpath +
                          ctx.attr.unused_dependency_checker_ignored_targets
        ] + [
            ctx.attr._junit.label,
            ctx.attr._hamcrest.label,
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
        _args.buildijar if hasattr(_args, "buildijar") else True,
        _args.implicit_junit_deps_needed_for_java_compilation if hasattr(_args, "implicit_junit_deps_needed_for_java_compilation") else [],
        _args.unused_dependency_checker_ignored_targets if hasattr(_args, "unused_dependency_checker_ignored_targets") else [],
        _args.unused_dependency_checker_mode if hasattr(_args, "unused_dependency_checker_mode") else p.unused_deps_checker,
    )

def _phase_compile(
        ctx,
        p,
        srcjars,
        buildijar,
        # TODO: generalize this hack
        implicit_junit_deps_needed_for_java_compilation,
        unused_dependency_checker_ignored_targets,
        unused_dependency_checker_mode):
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
        unused_dependency_checker_mode,
        unused_dependency_checker_ignored_targets,
        deps_providers,
        default_classpath,
    )

    # TODO: simplify the return values and use provider
    return struct(
        class_jar = out.class_jar,
        coverage = out.coverage,
        full_jars = out.full_jars,
        ijar = out.ijar,
        ijars = out.ijars,
        rjars = depset(out.full_jars, transitive = [rjars]),
        java_jar = out.java_jar,
        source_jars = _pack_source_jars(ctx) + out.source_jars,
        merged_provider = out.merged_provider,
        external_providers = [out.merged_provider] + out.coverage.providers,
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
        unused_dependency_checker_mode,
        unused_dependency_checker_ignored_targets,
        deps_providers,
        default_classpath):
    # We assume that if a srcjar is present, it is not empty
    if len(ctx.files.srcs) + len(srcjars.to_list()) == 0:
        _build_nosrc_jar(ctx)

        scala_compilation_provider = _create_scala_compilation_provider(ctx, ctx.outputs.jar, None, deps_providers)

        #  no need to build ijar when empty
        return struct(
            class_jar = ctx.outputs.jar,
            coverage = _empty_coverage_struct,
            full_jars = [ctx.outputs.jar],
            ijar = ctx.outputs.jar,
            ijars = [ctx.outputs.jar],
            java_jar = False,
            source_jars = [],
            merged_provider = scala_compilation_provider,
        )
    else:
        in_srcjars = [
            f
            for f in ctx.files.srcs
            if f.basename.endswith(_srcjar_extension)
        ]
        all_srcjars = depset(in_srcjars, transitive = [srcjars])

        java_srcs = [
            f
            for f in ctx.files.srcs
            if f.basename.endswith(_java_extension)
        ]

        # We are not able to verify whether dependencies are used when compiling java sources
        # Thus we disable unused dependency checking when java sources are found
        if len(java_srcs) != 0:
            unused_dependency_checker_mode = "off"

        sources = [
            f
            for f in ctx.files.srcs
            if f.basename.endswith(_scala_extension)
        ] + java_srcs
        _compile_scala(
            ctx,
            ctx.label,
            ctx.outputs.jar,
            manifest,
            ctx.outputs.statsfile,
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
            ctx.attr._scalac,
            unused_dependency_checker_ignored_targets =
                unused_dependency_checker_ignored_targets,
            unused_dependency_checker_mode = unused_dependency_checker_mode,
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

        source_jar = _pack_source_jar(ctx)
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
        ijars = [ijar]
        source_jars = []
        if java_jar:
            full_jars += [java_jar.jar]
            ijars += [java_jar.ijar]
            source_jars += java_jar.source_jars

        coverage = _jacoco_offline_instrument(ctx, ctx.outputs.jar)

        if java_jar:
            merged_provider = java_common.merge([scala_compilation_provider, java_jar.java_compilation_provider])
        else:
            merged_provider = scala_compilation_provider

        return struct(
            class_jar = ctx.outputs.jar,
            coverage = coverage,
            full_jars = full_jars,
            ijar = ijar,
            ijars = ijars,
            java_jar = java_jar,
            source_jars = source_jars,
            merged_provider = merged_provider,
        )

def _pack_source_jars(ctx):
    source_jar = _pack_source_jar(ctx)

    #_pack_source_jar may return None if java_common.pack_sources returned None (and it can)
    return [source_jar] if source_jar else []

def _build_nosrc_jar(ctx):
    resources = _add_resources_cmd(ctx)
    ijar_cmd = ""

    # this ensures the file is not empty
    resources += "META-INF/MANIFEST.MF=%s\n" % ctx.outputs.manifest.path

    zipper_arg_path = ctx.actions.declare_file("%s_zipper_args" % ctx.label.name)
    ctx.actions.write(zipper_arg_path, resources)
    cmd = """
rm -f {jar_output}
{zipper} c {jar_output} @{path}
# ensures that empty src targets still emit a statsfile
touch {statsfile}
""" + ijar_cmd

    cmd = cmd.format(
        path = zipper_arg_path.path,
        jar_output = ctx.outputs.jar.path,
        zipper = ctx.executable._zipper.path,
        statsfile = ctx.outputs.statsfile.path,
    )

    outs = [ctx.outputs.jar, ctx.outputs.statsfile]
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
    )

def _pack_source_jar(ctx):
    # collect .scala sources and pack a source jar for Scala
    scala_sources = [
        f
        for f in ctx.files.srcs
        if f.basename.endswith(_scala_extension)
    ]

    # collect .srcjar files and pack them with the scala sources
    bundled_source_jars = [
        f
        for f in ctx.files.srcs
        if f.basename.endswith(_srcjar_extension)
    ]
    scala_source_jar = java_common.pack_sources(
        ctx.actions,
        output_jar = ctx.outputs.jar,
        sources = scala_sources,
        source_jars = bundled_source_jars,
        java_toolchain = find_java_toolchain(ctx, ctx.attr._java_toolchain),
        host_javabase = find_java_runtime_toolchain(ctx, ctx.attr._host_javabase),
    )

    return scala_source_jar

def _jacoco_offline_instrument(ctx, input_jar):
    if not ctx.configuration.coverage_enabled or not hasattr(ctx.attr, "_code_coverage_instrumentation_worker"):
        return _empty_coverage_struct

    output_jar = ctx.actions.declare_file(
        "{}-offline.jar".format(input_jar.basename.split(".")[0]),
    )
    in_out_pairs = [
        (input_jar, output_jar),
    ]

    args = ctx.actions.args()
    args.add_all(in_out_pairs, map_each = _jacoco_offline_instrument_format_each)
    args.set_param_file_format("multiline")
    args.use_param_file("@%s", use_always = True)

    ctx.actions.run(
        mnemonic = "JacocoInstrumenter",
        inputs = [in_out_pair[0] for in_out_pair in in_out_pairs],
        outputs = [in_out_pair[1] for in_out_pair in in_out_pairs],
        executable = ctx.attr._code_coverage_instrumentation_worker.files_to_run,
        execution_requirements = {"supports-workers": "1"},
        arguments = [args],
    )

    replacements = {i: o for (i, o) in in_out_pairs}
    provider = _coverage_replacements_provider.create(
        replacements = replacements,
    )
    instrumented_files_provider = coverage_common.instrumented_files_info(
        ctx,
        source_attributes = ["srcs"],
        dependency_attributes = _coverage_replacements_provider.dependency_attributes,
        extensions = ["scala", "java"],
    )
    return struct(
        providers = [provider, instrumented_files_provider],
        replacements = replacements,
    )

def _jacoco_offline_instrument_format_each(in_out_pair):
    return (["%s=%s" % (in_out_pair[0].path, in_out_pair[1].path)])

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
    providers_of_dependencies += [scala_sources_java_provider]

    full_java_jar = ctx.actions.declare_file(ctx.label.name + "_java.jar")

    provider = java_common.compile(
        ctx,
        source_jars = all_srcjars.to_list(),
        source_files = java_srcs,
        output = full_java_jar,
        javac_opts = _expand_location(
            ctx,
            ctx.attr.javacopts + ctx.attr.javac_jvm_flags +
            java_common.default_javac_opts(
                java_toolchain = ctx.attr._java_toolchain[java_common.JavaToolchainInfo],
            ),
        ),
        deps = providers_of_dependencies,
        #exports can be empty since the manually created provider exposes exports
        #needs to be empty since we want the provider.compile_jars to only contain the sources ijar
        #workaround until https://github.com/bazelbuild/bazel/issues/3528 is resolved
        exports = [],
        java_toolchain = find_java_toolchain(ctx, ctx.attr._java_toolchain),
        host_javabase = find_java_runtime_toolchain(ctx, ctx.attr._host_javabase),
        strict_deps = ctx.fragments.java.strict_java_deps,
    )

    return struct(
        ijar = provider.compile_jars.to_list().pop(),
        jar = full_java_jar,
        source_jars = provider.source_jars,
        java_compilation_provider = provider,
    )

def _adjust_resources_path(resource, resource_strip_prefix):
    if resource_strip_prefix:
        return _adjust_resources_path_by_strip_prefix(resource, resource_strip_prefix)
    else:
        return _adjust_resources_path_by_default_prefixes(resource.path)

def _add_resources_cmd(ctx):
    res_cmd = []
    for f in ctx.files.resources:
        c_dir, res_path = _adjust_resources_path(
            f,
            ctx.attr.resource_strip_prefix,
        )
        target_path = res_path
        if target_path[0] == "/":
            target_path = target_path[1:]
        line = "{target_path}={c_dir}{res_path}\n".format(
            res_path = res_path,
            target_path = target_path,
            c_dir = c_dir,
        )
        res_cmd.extend([line])
    return "".join(res_cmd)

def _adjust_resources_path_by_strip_prefix(resource, resource_strip_prefix):
    path = resource.path
    prefix = _paths.join(resource.owner.workspace_root, resource_strip_prefix)
    if not path.startswith(prefix):
        fail("Resource file %s is not under the specified prefix %s to strip" % (path, prefix))

    clean_path = path[len(prefix):]
    return prefix, clean_path

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
