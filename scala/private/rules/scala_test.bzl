"""Rules for writing tests with ScalaTest"""

load(
    "@io_bazel_rules_scala//scala/private:common_attributes.bzl",
    "common_attrs",
    "implicit_deps",
    "launcher_template",
    "test_resolve_deps",
)
load("@io_bazel_rules_scala//scala/private:common.bzl", "sanitize_string_for_usage")
load("@io_bazel_rules_scala//scala/private:common_outputs.bzl", "common_outputs")
load(
    "@io_bazel_rules_scala//scala/private:coverage_replacements_provider.bzl",
    _coverage_replacements_provider = "coverage_replacements_provider",
)
load(
    "@io_bazel_rules_scala//scala/private:rule_impls.bzl",
    "collect_jars_from_common_ctx",
    "declare_executable",
    "expand_location",
    "first_non_empty",
    "get_scalac_provider",
    "get_unused_dependency_checker_mode",
    "scala_binary_common",
    "write_executable",
    "write_java_wrapper",
)

def _scala_test_flags(ctx):
    # output report test duration
    flags = "-oD"
    if ctx.attr.full_stacktraces:
        flags += "F"
    else:
        flags += "S"
    if not ctx.attr.colors:
        flags += "W"
    return flags

def _scala_test_impl(ctx):
    if len(ctx.attr.suites) != 0:
        print("suites attribute is deprecated. All scalatest test suites are run")

    scalac_provider = get_scalac_provider(ctx)

    unused_dependency_checker_mode = get_unused_dependency_checker_mode(ctx)
    unused_dependency_checker_ignored_targets = [
        target.label
        for target in scalac_provider.default_classpath +
                      ctx.attr.unused_dependency_checker_ignored_targets
    ]
    unused_dependency_checker_is_off = unused_dependency_checker_mode == "off"

    scalatest_base_classpath = scalac_provider.default_classpath + [ctx.attr._scalatest]
    jars = collect_jars_from_common_ctx(
        ctx,
        scalatest_base_classpath,
        extra_runtime_deps = [
            ctx.attr._scalatest_reporter,
            ctx.attr._scalatest_runner,
        ],
        unused_dependency_checker_is_off = unused_dependency_checker_is_off,
    )
    (
        cjars,
        transitive_rjars,
        transitive_compile_jars,
        jars_to_labels,
    ) = (
        jars.compile_jars,
        jars.transitive_runtime_jars,
        jars.transitive_compile_jars,
        jars.jars2labels,
    )

    args = "\n".join([
        "-R",
        ctx.outputs.jar.short_path,
        _scala_test_flags(ctx),
        "-C",
        "io.bazel.rules.scala.JUnitXmlReporter",
    ])

    argsFile = ctx.actions.declare_file("%s.args" % ctx.label.name)
    ctx.actions.write(argsFile, args)

    executable = declare_executable(ctx)

    wrapper = write_java_wrapper(ctx, "", "")
    out = scala_binary_common(
        ctx,
        executable,
        cjars,
        transitive_rjars,
        transitive_compile_jars,
        jars_to_labels,
        wrapper,
        unused_dependency_checker_ignored_targets =
            unused_dependency_checker_ignored_targets,
        unused_dependency_checker_mode = unused_dependency_checker_mode,
        runfiles_ext = [argsFile],
        deps_providers = jars.deps_providers,
    )

    rjars = out.transitive_rjars

    coverage_runfiles = []
    if ctx.configuration.coverage_enabled and _coverage_replacements_provider.is_enabled(ctx):
        coverage_replacements = _coverage_replacements_provider.from_ctx(
            ctx,
            base = out.coverage.replacements,
        ).replacements

        rjars = depset([
            coverage_replacements[jar] if jar in coverage_replacements else jar
            for jar in rjars.to_list()
        ])
        coverage_runfiles = ctx.files._jacocorunner + ctx.files._lcov_merger + coverage_replacements.values()

    # jvm_flags passed in on the target override scala_test_jvm_flags passed in on the
    # toolchain
    final_jvm_flags = first_non_empty(
        ctx.attr.jvm_flags,
        ctx.toolchains["@io_bazel_rules_scala//scala:toolchain_type"].scala_test_jvm_flags,
    )

    coverage_runfiles.extend(write_executable(
        ctx = ctx,
        executable = executable,
        jvm_flags = [
            "-DRULES_SCALA_MAIN_WS_NAME=%s" % ctx.workspace_name,
            "-DRULES_SCALA_ARGS_FILE=%s" % argsFile.short_path,
        ] + expand_location(ctx, final_jvm_flags),
        main_class = ctx.attr.main_class,
        rjars = rjars,
        use_jacoco = ctx.configuration.coverage_enabled,
        wrapper = wrapper,
    ))

    return struct(
        executable = executable,
        files = out.files,
        instrumented_files = out.instrumented_files,
        providers = out.providers,
        runfiles = ctx.runfiles(coverage_runfiles, transitive_files = out.runfiles.files),
        scala = out.scala,
    )

_scala_test_attrs = {
    "main_class": attr.string(
        default = "io.bazel.rulesscala.scala_test.Runner",
    ),
    "suites": attr.string_list(),
    "colors": attr.bool(default = True),
    "full_stacktraces": attr.bool(default = True),
    "_scalatest": attr.label(
        default = Label(
            "//external:io_bazel_rules_scala/dependency/scalatest/scalatest",
        ),
    ),
    "_scalatest_runner": attr.label(
        cfg = "host",
        default = Label("//src/java/io/bazel/rulesscala/scala_test:runner"),
    ),
    "_scalatest_reporter": attr.label(
        default = Label("//scala/support:test_reporter"),
    ),
    "_jacocorunner": attr.label(
        default = Label("@bazel_tools//tools/jdk:JacocoCoverage"),
    ),
    "_lcov_merger": attr.label(
        default = Label("@bazel_tools//tools/test/CoverageOutputGenerator/java/com/google/devtools/coverageoutputgenerator:Main"),
    ),
}

_scala_test_attrs.update(launcher_template)

_scala_test_attrs.update(implicit_deps)

_scala_test_attrs.update(common_attrs)

_scala_test_attrs.update(test_resolve_deps)

scala_test = rule(
    attrs = _scala_test_attrs,
    executable = True,
    fragments = ["java"],
    outputs = common_outputs,
    test = True,
    toolchains = ["@io_bazel_rules_scala//scala:toolchain_type"],
    implementation = _scala_test_impl,
)

# This auto-generates a test suite based on the passed set of targets
# we will add a root test_suite with the name of the passed name
def scala_test_suite(
        name,
        srcs = [],
        visibility = None,
        use_short_names = False,
        **kwargs):
    ts = []
    i = 0
    for test_file in srcs:
        i = i + 1
        n = ("%s_%s" % (name, i)) if use_short_names else ("%s_test_suite_%s" % (name, sanitize_string_for_usage(test_file)))
        scala_test(
            name = n,
            srcs = [test_file],
            visibility = visibility,
            unused_dependency_checker_mode = "off",
            **kwargs
        )
        ts.append(n)
    native.test_suite(name = name, tests = ts, visibility = visibility)
