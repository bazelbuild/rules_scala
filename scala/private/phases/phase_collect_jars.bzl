#
# PHASE: collect jars
#
# DOCUMENT THIS
#
load(
    "@io_bazel_rules_scala//scala/private:common.bzl",
    "collect_jars",
)

def phase_collect_jars_scalatest(ctx, p):
    args = struct(
        base_classpath = p.scalac_provider.default_classpath + [ctx.attr._scalatest],
        extra_runtime_deps = [
            ctx.attr._scalatest_reporter,
            ctx.attr._scalatest_runner,
        ],
    )
    return _phase_collect_jars_default(ctx, p, args)

def phase_collect_jars_repl(ctx, p):
    args = struct(
        base_classpath = p.scalac_provider.default_repl_classpath,
    )
    return _phase_collect_jars_default(ctx, p, args)

def phase_collect_jars_macro_library(ctx, p):
    args = struct(
        base_classpath = p.scalac_provider.default_macro_classpath,
    )
    return _phase_collect_jars_default(ctx, p, args)

def phase_collect_jars_junit_test(ctx, p):
    args = struct(
        extra_deps = [
            ctx.attr._junit,
            ctx.attr._hamcrest,
            ctx.attr.suite_label,
            ctx.attr._bazel_test_runner,
        ],
    )
    return _phase_collect_jars_default(ctx, p, args)

def phase_collect_jars_common(ctx, p):
    return _phase_collect_jars_default(ctx, p)

def _phase_collect_jars_default(ctx, p, _args = struct()):
    return _phase_collect_jars(
        ctx,
        p,
        _args.base_classpath if hasattr(_args, "base_classpath") else p.scalac_provider.default_classpath,
        _args.extra_deps if hasattr(_args, "extra_deps") else [],
        _args.extra_runtime_deps if hasattr(_args, "extra_runtime_deps") else [],
    )

# Extract very common code out from dependency analysis into single place
# automatically adds dependency on scala-library and scala-reflect
# collects jars from deps, runtime jars from runtime_deps, and
def _phase_collect_jars(
        ctx,
        p,
        base_classpath,
        extra_deps,
        extra_runtime_deps):
    deps_jars = collect_jars(
        ctx.attr.deps + extra_deps + base_classpath,
        p.dependency.dependency_mode,
        p.dependency.need_direct_info,
        p.dependency.need_indirect_info,
    )

    (
        cjars,
        transitive_rjars,
        jars2labels,
        transitive_compile_jars,
        deps_providers,
    ) = (
        deps_jars.compile_jars,
        deps_jars.transitive_runtime_jars,
        deps_jars.jars2labels,
        deps_jars.transitive_compile_jars,
        deps_jars.deps_providers,
    )

    transitive_rjars = depset(
        transitive = [transitive_rjars] +
                     _collect_runtime_jars(ctx.attr.runtime_deps + extra_runtime_deps),
    )

    return struct(
        compile_jars = cjars,
        jars2labels = jars2labels,
        transitive_compile_jars = transitive_compile_jars,
        transitive_runtime_jars = transitive_rjars,
        deps_providers = deps_providers,
        external_providers = {"JarsToLabelsInfo": jars2labels},
    )

def _collect_runtime_jars(dep_targets):
    runtime_jars = []

    for dep_target in dep_targets:
        runtime_jars.append(dep_target[JavaInfo].transitive_runtime_jars)

    return runtime_jars
