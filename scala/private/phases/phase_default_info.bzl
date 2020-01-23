#
# PHASE: default_info
#
# DOCUMENT THIS
#
def phase_default_info_binary(ctx, p):
    return struct(
        external_providers = [
            DefaultInfo(
                executable = p.declare_executable,
                files = depset([p.declare_executable] + p.compile.full_jars),
                runfiles = p.runfiles.runfiles,
            ),
        ],
    )

def phase_default_info_library(ctx, p):
    return struct(
        external_providers = [
            DefaultInfo(
                files = depset(p.compile.full_jars),
                runfiles = p.runfiles.runfiles,
            ),
        ],
    )

def phase_default_info_scalatest(ctx, p):
    return struct(
        external_providers = [
            DefaultInfo(
                executable = p.declare_executable,
                files = depset([p.declare_executable] + p.compile.full_jars),
                runfiles = ctx.runfiles(p.coverage_runfiles.coverage_runfiles, transitive_files = p.runfiles.runfiles.files),
            ),
        ],
    )
