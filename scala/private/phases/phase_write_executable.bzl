#
# PHASE: write executable
#
# DOCUMENT THIS
#
load(
    "@io_bazel_rules_scala//scala/private:rule_impls.bzl",
    "expand_location",
    "first_non_empty",
    "write_executable",
)

def phase_scalatest_write_executable(ctx, p):
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
    return _phase_deafult_write_executable(ctx, p, args)

def phase_repl_write_executable(ctx, p):
    args = struct(
        jvm_flags = ["-Dscala.usejavacp=true"] + ctx.attr.jvm_flags,
        main_class = "scala.tools.nsc.MainGenericRunner",
    )
    return _phase_deafult_write_executable(ctx, p, args)

def phase_junit_test_write_executable(ctx, p):
    args = struct(
        jvm_flags = p.jvm_flags + ctx.attr.jvm_flags,
        main_class = "com.google.testing.junit.runner.BazelTestRunner",
    )
    return _phase_deafult_write_executable(ctx, p, args)

def phase_common_write_executable(ctx, p):
    return _phase_deafult_write_executable(ctx, p)

def _phase_deafult_write_executable(ctx, p, _args = struct()):
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
    executable = p.declare_executable
    wrapper = p.java_wrapper

    return write_executable(
        ctx,
        executable,
        rjars,
        main_class,
        jvm_flags,
        wrapper,
        use_jacoco,
    )
