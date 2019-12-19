#
# PHASE: compile
#
# DOCUMENT THIS
#
load(
    "@io_bazel_rules_scala//scala/private:rule_impls.bzl",
    "compile_or_empty",
    "pack_source_jars",
)

def phase_binary_compile(ctx, p):
    args = struct(
        buildijar = False,
        unused_dependency_checker_ignored_targets = [
            target.label
            for target in p.scalac_provider.default_classpath +
                          ctx.attr.unused_dependency_checker_ignored_targets
        ],
    )
    return _phase_default_compile(ctx, p, args)

def phase_library_compile(ctx, p):
    args = struct(
        srcjars = p.collect_srcjars,
        unused_dependency_checker_ignored_targets = [
            target.label
            for target in p.scalac_provider.default_classpath + ctx.attr.exports +
                          ctx.attr.unused_dependency_checker_ignored_targets
        ],
    )
    return _phase_default_compile(ctx, p, args)

def phase_library_for_plugin_bootstrapping_compile(ctx, p):
    args = struct(
        unused_dependency_checker_ignored_targets = [
            target.label
            for target in p.scalac_provider.default_classpath + ctx.attr.exports
        ],
        unused_dependency_checker_mode = "off",
    )
    return _phase_default_compile(ctx, p, args)

def phase_macro_library_compile(ctx, p):
    args = struct(
        buildijar = False,
        unused_dependency_checker_ignored_targets = [
            target.label
            for target in p.scalac_provider.default_macro_classpath + ctx.attr.exports +
                          ctx.attr.unused_dependency_checker_ignored_targets
        ],
    )
    return _phase_default_compile(ctx, p, args)

def phase_junit_test_compile(ctx, p):
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
    return _phase_default_compile(ctx, p, args)

def phase_repl_compile(ctx, p):
    args = struct(
        buildijar = False,
        unused_dependency_checker_ignored_targets = [
            target.label
            for target in p.scalac_provider.default_repl_classpath +
                          ctx.attr.unused_dependency_checker_ignored_targets
        ],
    )
    return _phase_default_compile(ctx, p, args)

def phase_scalatest_compile(ctx, p):
    args = struct(
        buildijar = False,
        unused_dependency_checker_ignored_targets = [
            target.label
            for target in p.scalac_provider.default_classpath +
                          ctx.attr.unused_dependency_checker_ignored_targets
        ],
    )
    return _phase_default_compile(ctx, p, args)

def phase_common_compile(ctx, p):
    return _phase_default_compile(ctx, p)

def _phase_default_compile(ctx, p, _args = struct()):
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

    out = compile_or_empty(
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
        source_jars = pack_source_jars(ctx) + out.source_jars,
        merged_provider = out.merged_provider,
    )
