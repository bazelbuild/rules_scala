#
# PHASE: merge jars
#
# DOCUMENT THIS
#

def phase_merge_jars(ctx, p):
    """Calls Bazel's singlejar utility.

    For a full list of available command line options see:
    https://github.com/bazelbuild/bazel/blob/697d219526bffbecd29f29b402c9122ec5d9f2ee/src/java_tools/singlejar/java/com/google/devtools/build/singlejar/SingleJar.java#L337
    Use --compression to reduce size of deploy jars.
    """
    deploy_jar = ctx.outputs.deploy_jar
    runtime_jars = p.compile.rjars
    main_class = getattr(ctx.attr, "main_class", "")
    progress_message = "Merging Scala jar: %s" % ctx.label
    args = ctx.actions.args()
    args.add_all(["--compression", "--normalize", "--sources"])
    args.add_all(runtime_jars, map_each = _fileToPath)

    if main_class:
        args.add_all(["--main_class", main_class])
    args.add_all(["--output", deploy_jar.path])

    args.set_param_file_format("multiline")
    args.use_param_file("@%s", use_always = True)
    ctx.actions.run(
        inputs = runtime_jars,
        outputs = [deploy_jar],
        executable = ctx.executable._singlejar,
        mnemonic = "ScalaDeployJar",
        progress_message = progress_message,
        arguments = [args],
    )

def _fileToPath(file):
    return file.path