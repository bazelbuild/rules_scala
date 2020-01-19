#
# PHASE: final
#
# DOCUMENT THIS
#
def phase_binary_final(ctx, p):
    defaultInfo = DefaultInfo(
        executable = p.declare_executable,
        files = depset([p.declare_executable] + p.compile.full_jars),
        runfiles = p.runfiles.runfiles,
    )
    return [defaultInfo, p.compile.merged_provider, p.collect_jars.jars2labels] + p.compile.coverage.providers

def phase_library_final(ctx, p):
    defaultInfo = DefaultInfo(
        files = depset([ctx.outputs.jar] + p.compile.full_jars),  # Here is the default output
        runfiles = p.runfiles.runfiles,
    )
    return [defaultInfo, p.compile.merged_provider, p.collect_jars.jars2labels] + p.compile.coverage.providers

def phase_scalatest_final(ctx, p):
    defaultInfo = DefaultInfo(
        executable = p.declare_executable,
        files = depset([p.declare_executable] + p.compile.full_jars),
        runfiles = ctx.runfiles(p.coverage_runfiles.coverage_runfiles, transitive_files = p.runfiles.runfiles.files),
    )
    return [defaultInfo, p.compile.merged_provider, p.collect_jars.jars2labels] + p.compile.coverage.providers
