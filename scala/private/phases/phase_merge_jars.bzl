#
# PHASE: merge jars
#
# DOCUMENT THIS
#

def phase_merge_jars(ctx, p):
    _merge_jars(
        actions = ctx.actions,
        deploy_jar = ctx.outputs.deploy_jar,
        singlejar_executable = ctx.executable._singlejar,
        jars_list = p.compile.rjars.to_list(),
        main_class = getattr(ctx.attr, "main_class", ""),
        progress_message = "Merging Scala jar: %s" % ctx.label,
    )

def _merge_jars(actions, deploy_jar, singlejar_executable, jars_list, main_class = "", progress_message = ""):
    """Calls Bazel's singlejar utility.

    For a full list of available command line options see:
    https://github.com/bazelbuild/bazel/blob/697d219526bffbecd29f29b402c9122ec5d9f2ee/src/java_tools/singlejar/java/com/google/devtools/build/singlejar/SingleJar.java#L337
    Use --compression to reduce size of deploy jars.

    Args:
        actions: The actions module from ctx: https://docs.bazel.build/versions/master/skylark/lib/actions.html
        deploy_jar: The deploy jar, usually defined in ctx.outputs.
        singlejar_executable: The singlejar executable file.
        jars_list: The jars to pass to singlejar.
        main_class: The main class to run, if any. Defaults to an empty string.
        progress_message: A progress message to display when Bazel executes this action. Defaults to an empty string.
    """
    args = ["--compression", "--normalize", "--sources"]
    args.extend([j.path for j in jars_list])
    if main_class:
        args.extend(["--main_class", main_class])
    args.extend(["--output", deploy_jar.path])
    actions.run(
        inputs = jars_list,
        outputs = [deploy_jar],
        executable = singlejar_executable,
        mnemonic = "ScalaDeployJar",
        progress_message = progress_message,
        arguments = args,
    )
