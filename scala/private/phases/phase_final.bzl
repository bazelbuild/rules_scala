#
# PHASE: final
#
# DOCUMENT THIS
#
def phase_binary_final(ctx, p):
    defaultInfo = DefaultInfo(
        executable = p.declare_executable,
        files = depset([p.declare_executable, ctx.outputs.jar]),
        runfiles = p.runfiles.runfiles,
    )
    return struct(
        providers = [defaultInfo, p.compile.merged_provider, p.collect_jars.jars2labels] + p.compile.coverage.providers,
    )

def phase_library_final(ctx, p):
    defaultInfo = DefaultInfo(
        files = depset([ctx.outputs.jar] + p.compile.full_jars),  # Here is the default output
        runfiles = p.runfiles.runfiles,
    )
    return struct(
        providers = [defaultInfo, p.compile.merged_provider, p.collect_jars.jars2labels] + p.compile.coverage.providers,
    )

def phase_scalatest_final(ctx, p):
    coverage_runfiles = p.coverage_runfiles.coverage_runfiles
    coverage_runfiles.extend(p.write_executable)
    defaultInfo = DefaultInfo(
        executable = p.declare_executable,
        files = depset([p.declare_executable, ctx.outputs.jar]),
        runfiles = ctx.runfiles(coverage_runfiles, transitive_files = p.runfiles.runfiles.files),
    )
    return struct(
        providers = [defaultInfo, p.compile.merged_provider, p.collect_jars.jars2labels] + p.compile.coverage.providers,
    )
