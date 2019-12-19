#
# PHASE: collect jars
#
# DOCUMENT THIS
#
load(
    "@io_bazel_rules_scala//scala/private:rule_impls.bzl",
    "collect_jars_from_common_ctx",
)

def phase_scalatest_collect_jars(ctx, p):
    args = struct(
        base_classpath = p.scalac_provider.default_classpath + [ctx.attr._scalatest],
        extra_runtime_deps = [
            ctx.attr._scalatest_reporter,
            ctx.attr._scalatest_runner,
        ],
    )
    return _phase_default_collect_jars(ctx, p, args)

def phase_repl_collect_jars(ctx, p):
    args = struct(
        base_classpath = p.scalac_provider.default_repl_classpath,
    )
    return _phase_default_collect_jars(ctx, p, args)

def phase_macro_library_collect_jars(ctx, p):
    args = struct(
        base_classpath = p.scalac_provider.default_macro_classpath,
    )
    return _phase_default_collect_jars(ctx, p, args)

def phase_junit_test_collect_jars(ctx, p):
    args = struct(
        extra_deps = [
            ctx.attr._junit,
            ctx.attr._hamcrest,
            ctx.attr.suite_label,
            ctx.attr._bazel_test_runner,
        ],
    )
    return _phase_default_collect_jars(ctx, p, args)

def phase_library_for_plugin_bootstrapping_collect_jars(ctx, p):
    args = struct(
        unused_dependency_checker_mode = "off",
    )
    return _phase_default_collect_jars(ctx, p, args)

def phase_common_collect_jars(ctx, p):
    return _phase_default_collect_jars(ctx, p)

def _phase_default_collect_jars(ctx, p, _args = struct()):
    return _phase_collect_jars(
        ctx,
        _args.base_classpath if hasattr(_args, "base_classpath") else p.scalac_provider.default_classpath,
        _args.extra_deps if hasattr(_args, "extra_deps") else [],
        _args.extra_runtime_deps if hasattr(_args, "extra_runtime_deps") else [],
        _args.unused_dependency_checker_mode if hasattr(_args, "unused_dependency_checker_mode") else p.unused_deps_checker,
    )

def _phase_collect_jars(
        ctx,
        base_classpath,
        extra_deps,
        extra_runtime_deps,
        unused_dependency_checker_mode):
    return collect_jars_from_common_ctx(
        ctx,
        base_classpath,
        extra_deps,
        extra_runtime_deps,
        unused_dependency_checker_mode == "off",
    )
