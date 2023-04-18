#
# PHASE: merge jars
#
# DOCUMENT THIS
#
load(
    "@io_bazel_rules_scala//scala/private:rule_impls.bzl",
    "specified_java_compile_toolchain",
)

def merge_jars_to_output(ctx, output, jars):
    """Calls Bazel's singlejar utility.

    For a full list of available command line options see:
    https://github.com/bazelbuild/bazel/blob/697d219526bffbecd29f29b402c9122ec5d9f2ee/src/java_tools/singlejar/java/com/google/devtools/build/singlejar/SingleJar.java#L337
    Use --compression to reduce size of deploy jars.
    """
    main_class = getattr(ctx.attr, "main_class", "")
    progress_message = "Merging Scala jar %s: %s" % (output, ctx.label)
    args = ctx.actions.args()
    args.add_all(["--compression", "--normalize", "--sources"])
    args.add_all(jars, map_each = _fileToPath)

    if main_class:
        args.add_all(["--main_class", main_class])
    args.add_all(["--output", output.path])

    args.set_param_file_format("multiline")
    args.use_param_file("@%s")
    ctx.actions.run(
        inputs = jars,
        outputs = [output],
        executable = specified_java_compile_toolchain(ctx).single_jar,
        mnemonic = "ScalaDeployJar",
        progress_message = progress_message,
        arguments = [args],
    )

def phase_merge_jars(ctx, p):
    deploy_jar = ctx.outputs.deploy_jar
    runtime_jars = p.compile.rjars
    merge_jars_to_output(ctx, deploy_jar, runtime_jars)

def _fileToPath(file):
    return file.path
