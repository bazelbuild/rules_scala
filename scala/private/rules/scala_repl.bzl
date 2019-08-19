"""Rule for launching a Scala REPL with dependencies"""

load(
    "@io_bazel_rules_scala//scala/private:common_attributes.bzl",
    "common_attrs",
    "implicit_deps",
    "launcher_template",
    "resolve_deps",
)
load("@io_bazel_rules_scala//scala/private:common_outputs.bzl", "common_outputs")
load(
    "@io_bazel_rules_scala//scala/private:rule_impls.bzl",
    "collect_jars_from_common_ctx",
    "declare_executable",
    "get_scalac_provider",
    "get_unused_dependency_checker_mode",
    "scala_binary_common",
    "write_executable",
    "write_java_wrapper",
)

def _scala_repl_impl(ctx):
    scalac_provider = get_scalac_provider(ctx)

    unused_dependency_checker_mode = get_unused_dependency_checker_mode(ctx)
    unused_dependency_checker_is_off = unused_dependency_checker_mode == "off"

    # need scala-compiler for MainGenericRunner below
    jars = collect_jars_from_common_ctx(
        ctx,
        scalac_provider.default_repl_classpath,
        unused_dependency_checker_is_off = unused_dependency_checker_is_off,
    )
    (cjars, transitive_rjars) = (jars.compile_jars, jars.transitive_runtime_jars)

    args = " ".join(ctx.attr.scalacopts)

    executable = declare_executable(ctx)

    wrapper = write_java_wrapper(
        ctx,
        args,
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

    out = scala_binary_common(
        ctx,
        executable,
        cjars,
        transitive_rjars,
        jars.transitive_compile_jars,
        jars.jars2labels,
        wrapper,
        unused_dependency_checker_ignored_targets = [
            target.label
            for target in scalac_provider.default_repl_classpath +
                          ctx.attr.unused_dependency_checker_ignored_targets
        ],
        unused_dependency_checker_mode = unused_dependency_checker_mode,
        deps_providers = jars.deps_providers,
    )
    write_executable(
        ctx = ctx,
        executable = executable,
        jvm_flags = ["-Dscala.usejavacp=true"] + ctx.attr.jvm_flags,
        main_class = "scala.tools.nsc.MainGenericRunner",
        rjars = out.transitive_rjars,
        use_jacoco = False,
        wrapper = wrapper,
    )

    return out

_scala_repl_attrs = {}

_scala_repl_attrs.update(launcher_template)

_scala_repl_attrs.update(implicit_deps)

_scala_repl_attrs.update(common_attrs)

_scala_repl_attrs.update(resolve_deps)

scala_repl = rule(
    attrs = _scala_repl_attrs,
    executable = True,
    fragments = ["java"],
    outputs = common_outputs,
    toolchains = ["@io_bazel_rules_scala//scala:toolchain_type"],
    implementation = _scala_repl_impl,
)
