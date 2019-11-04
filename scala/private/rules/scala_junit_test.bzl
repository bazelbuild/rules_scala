"""Rules for writing tests with JUnit"""

load(
    "@io_bazel_rules_scala//scala/private:common_attributes.bzl",
    "common_attrs",
    "implicit_deps",
    "launcher_template",
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

def _gen_test_suite_flags_based_on_prefixes_and_suffixes(ctx, archives):
    return struct(
        archiveFlag = "-Dbazel.discover.classes.archives.file.paths=%s" %
                      archives,
        prefixesFlag = "-Dbazel.discover.classes.prefixes=%s" % ",".join(
            ctx.attr.prefixes,
        ),
        printFlag = "-Dbazel.discover.classes.print.discovered=%s" %
                    ctx.attr.print_discovered_classes,
        suffixesFlag = "-Dbazel.discover.classes.suffixes=%s" % ",".join(
            ctx.attr.suffixes,
        ),
        testSuiteFlag = "-Dbazel.test_suite=%s" % ctx.attr.suite_class,
    )

def _serialize_archives_short_path(archives):
    archives_short_path = ""
    for archive in archives:
        archives_short_path += archive.short_path + ","
    return archives_short_path[:-1]  #remove redundant comma

def _get_test_archive_jars(ctx, test_archives):
    flattened_list = []
    for archive in test_archives:
        class_jars = [java_output.class_jar for java_output in archive[JavaInfo].outputs.jars]
        flattened_list.extend(class_jars)
    return flattened_list

def _scala_junit_test_impl(ctx):
    if (not (ctx.attr.prefixes) and not (ctx.attr.suffixes)):
        fail(
            "Setting at least one of the attributes ('prefixes','suffixes') is required",
        )
    scalac_provider = get_scalac_provider(ctx)

    unused_dependency_checker_mode = get_unused_dependency_checker_mode(ctx)
    unused_dependency_checker_ignored_targets = [
        target.label
        for target in scalac_provider.default_classpath +
                      ctx.attr.unused_dependency_checker_ignored_targets
    ] + [
        ctx.attr._junit.label,
        ctx.attr._hamcrest.label,
        ctx.attr.suite_label.label,
        ctx.attr._bazel_test_runner.label,
    ]
    unused_dependency_checker_is_off = unused_dependency_checker_mode == "off"

    jars = collect_jars_from_common_ctx(
        ctx,
        scalac_provider.default_classpath,
        extra_deps = [
            ctx.attr._junit,
            ctx.attr._hamcrest,
            ctx.attr.suite_label,
            ctx.attr._bazel_test_runner,
        ],
        unused_dependency_checker_is_off = unused_dependency_checker_is_off,
    )
    (cjars, transitive_rjars) = (jars.compile_jars, jars.transitive_runtime_jars)
    implicit_junit_deps_needed_for_java_compilation = [
        ctx.attr._junit,
        ctx.attr._hamcrest,
    ]

    executable = declare_executable(ctx)

    wrapper = write_java_wrapper(ctx, "", "")
    out = scala_binary_common(
        ctx,
        executable,
        cjars,
        transitive_rjars,
        jars.transitive_compile_jars,
        jars.jars2labels,
        wrapper,
        implicit_junit_deps_needed_for_java_compilation =
            implicit_junit_deps_needed_for_java_compilation,
        unused_dependency_checker_ignored_targets =
            unused_dependency_checker_ignored_targets,
        unused_dependency_checker_mode = unused_dependency_checker_mode,
        deps_providers = jars.deps_providers,
    )

    if ctx.attr.tests_from:
        archives = _get_test_archive_jars(ctx, ctx.attr.tests_from)
    else:
        archives = out.providers[0].runtime_output_jars

    serialized_archives = _serialize_archives_short_path(archives)
    test_suite = _gen_test_suite_flags_based_on_prefixes_and_suffixes(
        ctx,
        serialized_archives,
    )
    launcherJvmFlags = [
        "-ea",
        test_suite.archiveFlag,
        test_suite.prefixesFlag,
        test_suite.suffixesFlag,
        test_suite.printFlag,
        test_suite.testSuiteFlag,
    ]
    write_executable(
        ctx = ctx,
        executable = executable,
        jvm_flags = launcherJvmFlags + ctx.attr.jvm_flags,
        main_class = "com.google.testing.junit.runner.BazelTestRunner",
        rjars = out.transitive_rjars,
        use_jacoco = False,
        wrapper = wrapper,
    )

    return out

_scala_junit_test_attrs = {
    "prefixes": attr.string_list(default = []),
    "suffixes": attr.string_list(default = []),
    "suite_label": attr.label(
        default = Label(
            "//src/java/io/bazel/rulesscala/test_discovery:test_discovery",
        ),
    ),
    "suite_class": attr.string(
        default = "io.bazel.rulesscala.test_discovery.DiscoveredTestSuite",
    ),
    "print_discovered_classes": attr.bool(
        default = False,
        mandatory = False,
    ),
    "jvm_flags": attr.string_list(),
    "_junit": attr.label(
        default = Label(
            "//external:io_bazel_rules_scala/dependency/junit/junit",
        ),
    ),
    "_hamcrest": attr.label(
        default = Label(
            "//external:io_bazel_rules_scala/dependency/hamcrest/hamcrest_core",
        ),
    ),
    "_bazel_test_runner": attr.label(
        default = Label(
            "@io_bazel_rules_scala//scala:bazel_test_runner_deploy",
        ),
        allow_files = True,
    ),
}

_junit_resolve_deps = {
    "_scala_toolchain": attr.label_list(
        default = [
            Label(
                "//external:io_bazel_rules_scala/dependency/scala/scala_library",
            ),
            Label("//external:io_bazel_rules_scala/dependency/junit/junit"),
            Label(
                "//external:io_bazel_rules_scala/dependency/hamcrest/hamcrest_core",
            ),
        ],
        allow_files = False,
    ),
}

_scala_junit_test_attrs.update(launcher_template)

_scala_junit_test_attrs.update(implicit_deps)

_scala_junit_test_attrs.update(common_attrs)

_scala_junit_test_attrs.update(_junit_resolve_deps)

_scala_junit_test_attrs.update({
    "tests_from": attr.label_list(providers = [[JavaInfo]]),
})

scala_junit_test = rule(
    attrs = _scala_junit_test_attrs,
    fragments = ["java"],
    outputs = common_outputs,
    test = True,
    toolchains = ["@io_bazel_rules_scala//scala:toolchain_type"],
    implementation = _scala_junit_test_impl,
)
