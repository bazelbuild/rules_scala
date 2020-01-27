#
# PHASE: runfiles
#
# DOCUMENT THIS
#
def phase_runfiles_library(ctx, p):
    args = struct(
        # Using transitive_files since transitive_rjars a depset and avoiding linearization
        transitive_files = p.compile.rjars,
    )
    return _phase_runfiles_default(ctx, p, args)

def phase_runfiles_scalatest(ctx, p):
    args = "\n".join([
        "-R",
        ctx.outputs.jar.short_path,
        _scala_test_flags(ctx),
        "-C",
        "io.bazel.rules.scala.JUnitXmlReporter",
    ])
    args_file = ctx.actions.declare_file("%s.args" % ctx.label.name)
    ctx.actions.write(args_file, args)
    runfiles_ext = [args_file]

    args = struct(
        transitive_files = depset(
            [p.declare_executable, p.java_wrapper] + ctx.files._java_runtime + runfiles_ext,
            transitive = [p.compile.rjars],
        ),
        args_file = args_file,
    )
    return _phase_runfiles_default(ctx, p, args)

def phase_runfiles_common(ctx, p):
    return _phase_runfiles_default(ctx, p)

def _phase_runfiles_default(ctx, p, _args = struct()):
    return _phase_runfiles(
        ctx,
        _args.transitive_files if hasattr(_args, "transitive_files") else depset(
            [p.java_wrapper] + ctx.files._java_runtime,
            transitive = [p.compile.rjars],
        ),
        _args.args_file if hasattr(_args, "args_file") else None,
    )

def _phase_runfiles(
        ctx,
        transitive_files,
        args_file):
    return struct(
        runfiles = transitive_files,
        args_file = args_file,
    )

def _scala_test_flags(ctx):
    # output report test duration
    flags = "-oD"
    if ctx.attr.full_stacktraces:
        flags += "F"
    else:
        flags += "S"
    if not ctx.attr.colors:
        flags += "W"
    return flags
