#
# PHASE: default_info
#
# DOCUMENT THIS
#

def phase_default_info(ctx, p):
    executable = None
    files = []
    runfiles = []

    phase_names = dir(p)
    phase_names.remove("to_json")
    phase_names.remove("to_proto")
    for phase_name in phase_names:
        phase = getattr(p, phase_name)

        if hasattr(phase, "executable"):
            if executable == None:
                executable = phase.executable
            else:
                fail("only one executable may be provided")

        if hasattr(phase, "files"):
            files.append(phase.files)

        if hasattr(phase, "runfiles"):
            runfiles.append(phase.runfiles)

    return struct(
        external_providers = {
            "DefaultInfo": DefaultInfo(
                executable = executable,
                files = depset(transitive = files),
                runfiles = ctx.runfiles(transitive_files = depset(transitive = runfiles)),
            ),
        },
    )
