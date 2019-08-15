"""Builds Scala binaries"""

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
    "get_unused_dependency_checker_mode",
    "scala_binary_common",
    "scalac_provider",
    "write_executable",
    "write_java_wrapper",
)

def _scala_binary_impl(ctx):
    _scalac_provider = scalac_provider(ctx)
    unused_dependency_checker_mode = get_unused_dependency_checker_mode(ctx)
    unused_dependency_checker_is_off = unused_dependency_checker_mode == "off"

    jars = collect_jars_from_common_ctx(
        ctx,
        _scalac_provider.default_classpath,
        unused_dependency_checker_is_off = unused_dependency_checker_is_off,
    )
    (cjars, transitive_rjars) = (jars.compile_jars, jars.transitive_runtime_jars)

    wrapper = write_java_wrapper(ctx, "", "")

    executable = declare_executable(ctx)

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
            for target in _scalac_provider.default_classpath +
                          ctx.attr.unused_dependency_checker_ignored_targets
        ],
        unused_dependency_checker_mode = unused_dependency_checker_mode,
        deps_providers = jars.deps_providers,
    )
    write_executable(
        ctx = ctx,
        executable = executable,
        jvm_flags = ctx.attr.jvm_flags,
        main_class = ctx.attr.main_class,
        rjars = out.transitive_rjars,
        use_jacoco = False,
        wrapper = wrapper,
    )
    return out

_scala_binary_attrs = {
    "main_class": attr.string(mandatory = True),
    "classpath_resources": attr.label_list(allow_files = True),
}

_scala_binary_attrs.update(launcher_template)

_scala_binary_attrs.update(implicit_deps)

_scala_binary_attrs.update(common_attrs)

_scala_binary_attrs.update(resolve_deps)

scala_binary = rule(
    attrs = _scala_binary_attrs,
    executable = True,
    fragments = ["java"],
    outputs = common_outputs,
    toolchains = ["@io_bazel_rules_scala//scala:toolchain_type"],
    implementation = _scala_binary_impl,
)
