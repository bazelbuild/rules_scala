#
# PHASE: java wrapper
#
# DOCUMENT THIS
#
load(
    "@io_bazel_rules_scala//scala/private:rule_impls.bzl",
    _java_bin = "java_bin",
)

def phase_repl_java_wrapper(ctx, p):
    args = struct(
        args = " ".join(ctx.attr.scalacopts),
        wrapper_preamble = """
# save stty like in bin/scala
saved_stty=$(stty -g 2>/dev/null)
if [[ ! $? ]]; then
  saved_stty=""
fi
function finish() {
  if [[ "$saved_stty" != "" ]]; then
    stty $saved_stty
    saved_stty=""
  fi
}
trap finish EXIT
""",
    )
    return _phase_default_java_wrapper(ctx, p, args)

def phase_common_java_wrapper(ctx, p):
    return _phase_default_java_wrapper(ctx, p)

def _phase_default_java_wrapper(ctx, p, _args = struct()):
    return _phase_java_wrapper(
        ctx,
        _args.args if hasattr(_args, "args") else "",
        _args.wrapper_preamble if hasattr(_args, "wrapper_preamble") else "",
    )

def _phase_java_wrapper(
        ctx,
        args,
        wrapper_preamble):
    return write_java_wrapper(
        ctx,
        args,
        wrapper_preamble,
    )
def write_java_wrapper(ctx, args = "", wrapper_preamble = ""):
    """This creates a wrapper that sets up the correct path
         to stand in for the java command."""

    exec_str = ""
    if wrapper_preamble == "":
        exec_str = "exec "

    wrapper = ctx.actions.declare_file(ctx.label.name + "_wrapper.sh")
    ctx.actions.write(
        output = wrapper,
        content = """#!/usr/bin/env bash
{preamble}
DEFAULT_JAVABIN={javabin}
JAVA_EXEC_TO_USE=${{REAL_EXTERNAL_JAVA_BIN:-$DEFAULT_JAVABIN}}
{exec_str}$JAVA_EXEC_TO_USE "$@" {args}
""".format(
            preamble = wrapper_preamble,
            exec_str = exec_str,
            javabin = _java_bin(ctx),
            args = args,
        ),
        is_executable = True,
    )
    return wrapper

