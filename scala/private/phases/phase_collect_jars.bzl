#
# PHASE: collect jars
#
# DOCUMENT THIS
#
load(
    "@io_bazel_rules_scala//scala/private:rule_impls.bzl",
    "is_dependency_analyzer_off",
    "is_plus_one_deps_off",
)
load(
    "@io_bazel_rules_scala//scala/private:common.bzl",
    "collect_jars",
)

def phase_collect_jars_scalatest(ctx, p):
    boostrap_classpath = ctx.toolchains["@io_bazel_rules_scala//scala:bootstrap_toolchain_type"].bootstrapinfo.classpath
    test_classpath = ctx.toolchains["@io_bazel_rules_scala//scala:scala_test_toolchain_type"].scalatestinfo.deps
    args = struct(
        base_classpath = boostrap_classpath + test_classpath,
        extra_runtime_deps = [
            ctx.toolchains["@io_bazel_rules_scala//scala:scala_test_toolchain_type"].scalatestinfo.reporter,
            ctx.toolchains["@io_bazel_rules_scala//scala:scala_test_toolchain_type"].scalatestinfo.runner,
        ],
    )
    return _phase_collect_jars_default(ctx, p, args)

def phase_collect_jars_repl(ctx, p):
    args = struct(
        base_classpath = ctx.toolchains["@io_bazel_rules_scala//scala:bootstrap_toolchain_type"].bootstrapinfo.repl_classpath,
    )
    return _phase_collect_jars_default(ctx, p, args)

def phase_collect_jars_macro_library(ctx, p):
    args = struct(
        base_classpath = ctx.toolchains["@io_bazel_rules_scala//scala:bootstrap_toolchain_type"].bootstrapinfo.macro_classpath,
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

def phase_collect_jars_library_for_plugin_bootstrapping(ctx, p):
    args = struct(
        unused_dependency_checker_mode = "off",
    )
    return _phase_collect_jars_default(ctx, p, args)

def phase_collect_jars_common(ctx, p):
    return _phase_collect_jars_default(ctx, p)

def _phase_collect_jars_default(ctx, p, _args = struct()):
    return _phase_collect_jars(
        ctx,
        _args.base_classpath if hasattr(_args, "base_classpath") else ctx.toolchains["@io_bazel_rules_scala//scala:bootstrap_toolchain_type"].bootstrapinfo.classpath,
        _args.extra_deps if hasattr(_args, "extra_deps") else [],
        _args.extra_runtime_deps if hasattr(_args, "extra_runtime_deps") else [],
        _args.unused_dependency_checker_mode if hasattr(_args, "unused_dependency_checker_mode") else p.unused_deps_checker,
    )

# Extract very common code out from dependency analysis into single place
# automatically adds dependency on scala-library and scala-reflect
# collects jars from deps, runtime jars from runtime_deps, and
def _phase_collect_jars(
        ctx,
        base_classpath,
        extra_deps,
        extra_runtime_deps,
        unused_dependency_checker_mode):
    unused_dependency_checker_is_off = unused_dependency_checker_mode == "off"
    dependency_analyzer_is_off = is_dependency_analyzer_off(ctx)

    deps_jars = collect_jars(
        ctx.attr.deps + extra_deps + base_classpath,
        dependency_analyzer_is_off,
        unused_dependency_checker_is_off,
        is_plus_one_deps_off(ctx),
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
