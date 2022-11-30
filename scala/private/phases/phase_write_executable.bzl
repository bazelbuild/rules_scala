#
# PHASE: write executable
#
# DOCUMENT THIS
#
load(
    "@io_bazel_rules_scala//scala/private:rule_impls.bzl",
    "expand_location",
    "first_non_empty",
    "is_windows",
    "java_bin",
    "runfiles_root",
)

def phase_write_executable_scalatest(ctx, p):
    # jvm_flags passed in on the target override scala_test_jvm_flags passed in on the
    # toolchain
    final_jvm_flags = first_non_empty(
        ctx.attr.jvm_flags,
        ctx.toolchains["@io_bazel_rules_scala//scala:toolchain_type"].scala_test_jvm_flags,
    )
    args = struct(
        rjars = p.coverage_runfiles.rjars,
        jvm_flags = [
            "-DRULES_SCALA_MAIN_WS_NAME=%s" % ctx.workspace_name,
            "-DRULES_SCALA_ARGS_FILE=%s" % p.runfiles.args_file.short_path,
        ] + expand_location(ctx, final_jvm_flags),
        use_jacoco = ctx.configuration.coverage_enabled,
    )
    return _phase_write_executable_default(ctx, p, args)

def phase_write_executable_repl(ctx, p):
    args = struct(
        jvm_flags = ["-Dscala.usejavacp=true"] + ctx.attr.jvm_flags,
        main_class = "scala.tools.nsc.MainGenericRunner",
    )
    return _phase_write_executable_default(ctx, p, args)

def phase_write_executable_junit_test(ctx, p):
    args = struct(
        rjars = p.coverage_runfiles.rjars,
        jvm_flags = p.jvm_flags + ctx.attr.jvm_flags,
        main_class = "com.google.testing.junit.runner.BazelTestRunner",
        use_jacoco = ctx.configuration.coverage_enabled,
    )
    return _phase_write_executable_default(ctx, p, args)

def phase_write_executable_common(ctx, p):
    return _phase_write_executable_default(ctx, p)

def _phase_write_executable_default(ctx, p, _args = struct()):
    return _phase_write_executable(
        ctx,
        p,
        _args.rjars if hasattr(_args, "rjars") else p.compile.rjars,
        _args.jvm_flags if hasattr(_args, "jvm_flags") else ctx.attr.jvm_flags,
        _args.use_jacoco if hasattr(_args, "use_jacoco") else False,
        _args.main_class if hasattr(_args, "main_class") else ctx.attr.main_class,
    )

def _phase_write_executable(
        ctx,
        p,
        rjars,
        jvm_flags,
        use_jacoco,
        main_class):
    executable = p.declare_executable.executable
    wrapper = p.java_wrapper

    if (is_windows(ctx)):
        return _write_executable_windows(ctx, executable, rjars, main_class, jvm_flags, wrapper, use_jacoco)
    else:
        return _write_executable_non_windows(ctx, executable, rjars, main_class, jvm_flags, wrapper, use_jacoco)

def _write_executable_windows(ctx, executable, rjars, main_class, jvm_flags, wrapper, use_jacoco):
    # NOTE: `use_jacoco` is currently ignored on Windows.
    # TODO: tests coverage support for Windows
    classpath = ";".join(
        [("external/%s" % (j.short_path[3:]) if j.short_path.startswith("../") else j.short_path) for j in rjars.to_list()],
    )
    jvm_flags_str = ";".join(jvm_flags)
    java_for_exe = str(ctx.attr._java_runtime[java_common.JavaRuntimeInfo].java_executable_exec_path)

    cpfile = ctx.actions.declare_file("%s.classpath" % ctx.label.name)
    ctx.actions.write(cpfile, classpath)

    ctx.actions.run(
        outputs = [executable],
        inputs = [cpfile],
        executable = ctx.attr._exe.files_to_run.executable,
        arguments = [executable.path, ctx.workspace_name, java_for_exe, main_class, cpfile.path, jvm_flags_str],
        env = ctx.attr.env,
        mnemonic = "ExeLauncher",
        progress_message = "Creating exe launcher",
    )
    return []

def _write_executable_non_windows(ctx, executable, rjars, main_class, jvm_flags, wrapper, use_jacoco):
    template = ctx.attr._java_stub_template.files.to_list()[0]

    jvm_flags = " ".join(
        [ctx.expand_location(f, ctx.attr.data) for f in jvm_flags],
    )

    javabin = "export REAL_EXTERNAL_JAVA_BIN=${JAVABIN};JAVABIN=${JAVABIN:-%s/%s}" % (
        runfiles_root(ctx),
        wrapper.short_path,
    )

    scala_toolchain = ctx.toolchains["//scala:toolchain_type"]

    test_runner_classpath_mode = "argsfile" if scala_toolchain.use_argument_file_in_runner else "manifest" 
    
    if use_jacoco and ctx.configuration.coverage_enabled:
        jacocorunner = scala_toolchain.jacocorunner
        classpath = ctx.configuration.host_path_separator.join(
            ["${RUNPATH}%s" % (j.short_path) for j in rjars.to_list() + jacocorunner.files.to_list()],
        )
        jacoco_metadata_file = ctx.actions.declare_file(
            "%s.jacoco_metadata.txt" % ctx.attr.name,
            sibling = executable,
        )
        ctx.actions.write(jacoco_metadata_file, "\n".join([
            jar.short_path.replace("../", "external/")
            for jar in rjars.to_list()
        ]))
        ctx.actions.expand_template(
            template = template,
            output = executable,
            substitutions = {
                "%classpath%": "\"%s\"" % classpath,
                "%javabin%": javabin,
                "%jarbin%": _jar_path_based_on_java_bin(ctx),
                "%jvm_flags%": jvm_flags,
                "%needs_runfiles%": "",
                "%runfiles_manifest_only%": "",
                "%workspace_prefix%": ctx.workspace_name + "/",
                "%java_start_class%": "com.google.testing.coverage.JacocoCoverageRunner",
                "%set_jacoco_metadata%": "export JACOCO_METADATA_JAR=\"$JAVA_RUNFILES/{}/{}\"".format(ctx.workspace_name, jacoco_metadata_file.short_path),
                "%set_jacoco_main_class%": """export JACOCO_MAIN_CLASS={}""".format(main_class),
                "%set_jacoco_java_runfiles_root%": """export JACOCO_JAVA_RUNFILES_ROOT=$JAVA_RUNFILES/{}/""".format(ctx.workspace_name),
                "%set_java_coverage_new_implementation%": """export JAVA_COVERAGE_NEW_IMPLEMENTATION=YES""",
                "%test_runner_classpath_mode%": test_runner_classpath_mode,
            },
            is_executable = True,
        )
        return [jacoco_metadata_file]
    else:
        # RUNPATH is defined here:
        # https://github.com/bazelbuild/bazel/blob/0.4.5/src/main/java/com/google/devtools/build/lib/bazel/rules/java/java_stub_template.txt#L227
        classpath = ctx.configuration.host_path_separator.join(
            ["${RUNPATH}%s" % (j.short_path) for j in rjars.to_list()],
        )
        ctx.actions.expand_template(
            template = template,
            output = executable,
            substitutions = {
                "%classpath%": "\"%s\"" % classpath,
                "%java_start_class%": main_class,
                "%javabin%": javabin,
                "%jarbin%": _jar_path_based_on_java_bin(ctx),
                "%jvm_flags%": jvm_flags,
                "%needs_runfiles%": "",
                "%runfiles_manifest_only%": "",
                "%set_jacoco_metadata%": "",
                "%set_jacoco_main_class%": "",
                "%set_jacoco_java_runfiles_root%": "",
                "%workspace_prefix%": ctx.workspace_name + "/",
                "%set_java_coverage_new_implementation%": """export JAVA_COVERAGE_NEW_IMPLEMENTATION=NO""",
                "%test_runner_classpath_mode%": test_runner_classpath_mode,
            },
            is_executable = True,
        )
        return []

def _jar_path_based_on_java_bin(ctx):
    java_bin_var = java_bin(ctx)
    jar_path = java_bin_var.rpartition("/")[0] + "/jar"
    return jar_path
