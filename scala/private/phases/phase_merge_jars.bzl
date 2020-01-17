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
    jars_list = p.compile.rjars.to_list()
    main_class = getattr(ctx.attr, "main_class", "")
    progress_message = "Merging Scala jar: %s" % ctx.label
    args = ["--compression", "--normalize", "--sources"]
    args.extend([j.path for j in jars_list])
    if main_class:
        args.extend(["--main_class", main_class])
    args.extend(["--output", deploy_jar.path])
    ctx.actions.run(
        inputs = jars_list,
        outputs = [deploy_jar],
        executable = ctx.executable._singlejar,
        mnemonic = "ScalaDeployJar",
        progress_message = progress_message,
        arguments = args,
    )
