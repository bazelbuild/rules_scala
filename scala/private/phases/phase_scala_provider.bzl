#
# PHASE: scala provider
#
# DOCUMENT THIS
#
load(
    "@io_bazel_rules_scala//scala:providers.bzl",
    "create_scala_provider",
)

def phase_library_scala_provider(ctx, p):
    args = struct(
        rjars = depset(
            transitive = [p.compile.rjars, p.init.exports_jars.transitive_runtime_jars],
        ),
        compile_jars = depset(
            p.compile.ijars,
            transitive = [p.init.exports_jars.compile_jars],
        ),
    )
    return phase_common_scala_provider(ctx, p, args)

def phase_common_scala_provider(ctx, p, _args = struct()):
    return _phase_scala_provider(
        ctx,
        p,
        _args.rjars if hasattr(_args, "rjars") else p.compile.rjars,
        _args.compile_jars if hasattr(_args, "compile_jars") else depset(p.compile.ijars),
    )

def _phase_scala_provider(
        ctx,
        p,
        rjars,
        compile_jars):
    return create_scala_provider(
        class_jar = p.compile.class_jar,
        compile_jars = compile_jars,
        deploy_jar = ctx.outputs.deploy_jar,
        full_jars = p.compile.full_jars,
        ijar = p.compile.class_jar,  # we aren't using ijar here
        source_jars = p.compile.source_jars,
        statsfile = ctx.outputs.statsfile,
        transitive_runtime_jars = rjars,
    )
