#
# PHASE: final
#
# DOCUMENT THIS
#
def phase_binary_final(ctx, p):
    return struct(
        executable = p.declare_executable,
        coverage = p.compile.coverage,
        files = depset([p.declare_executable, ctx.outputs.jar]),
        instrumented_files = p.compile.coverage.instrumented_files,
        providers = [p.compile.merged_provider, p.collect_jars.jars2labels] + p.compile.coverage.providers,
        runfiles = p.runfiles.runfiles,
        transitive_rjars = p.compile.rjars,  #calling rules need this for the classpath in the launcher
    )

def phase_library_final(ctx, p):
    return struct(
        files = depset([ctx.outputs.jar] + p.compile.full_jars),  # Here is the default output
        instrumented_files = p.compile.coverage.instrumented_files,
        jars_to_labels = p.collect_jars.jars2labels,
        providers = [p.compile.merged_provider, p.collect_jars.jars2labels] + p.compile.coverage.providers,
        runfiles = p.runfiles.runfiles,
    )

def phase_scalatest_final(ctx, p):
    coverage_runfiles = p.coverage_runfiles.coverage_runfiles
    coverage_runfiles.extend(p.write_executable)
    return struct(
        executable = p.declare_executable,
        files = depset([p.declare_executable, ctx.outputs.jar]),
        instrumented_files = p.compile.coverage.instrumented_files,
        providers = [p.compile.merged_provider, p.collect_jars.jars2labels] + p.compile.coverage.providers,
        runfiles = ctx.runfiles(coverage_runfiles, transitive_files = p.runfiles.runfiles.files),
    )
