#
# PHASE: default_info
#
# DOCUMENT THIS
#
def phase_binary_default_info(ctx, p):
    return struct(
        external_providers = {
            "DefaultInfo": DefaultInfo(
                executable = p.declare_executable,
                files = depset([p.declare_executable] + p.compile.full_jars),
                runfiles = p.runfiles.runfiles,
            ),
        },
    )

def phase_library_default_info(ctx, p):
    return struct(
        external_providers = {
            "DefaultInfo": DefaultInfo(
                files = depset(p.compile.full_jars),
                runfiles = p.runfiles.runfiles,
            ),
        },
    )

def phase_scalatest_default_info(ctx, p):
    return struct(
        external_providers = {
            "DefaultInfo": DefaultInfo(
                executable = p.declare_executable,
                files = depset([p.declare_executable] + p.compile.full_jars),
                runfiles = ctx.runfiles(p.coverage_runfiles.coverage_runfiles, transitive_files = p.runfiles.runfiles.files),
            ),
        },
    )
