#
# PHASE: java wrapper
#
# DOCUMENT THIS
#
load(
    "@io_bazel_rules_scala//scala/private:rule_impls.bzl",
    "write_java_wrapper",
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
    return phase_common_java_wrapper(ctx, p, args)

def phase_common_java_wrapper(ctx, p, _args = struct()):
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
