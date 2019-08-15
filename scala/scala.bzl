load(
    "@io_bazel_rules_scala//scala/private:rule_impls.bzl",
    _scala_junit_test_impl = "scala_junit_test_impl",
    _scala_library_for_plugin_bootstrapping_impl = "scala_library_for_plugin_bootstrapping_impl",
    _scala_library_impl = "scala_library_impl",
    _scala_macro_library_impl = "scala_macro_library_impl",
    _scala_repl_impl = "scala_repl_impl",
    _scala_test_impl = "scala_test_impl",
)
load(
    "@io_bazel_rules_scala//scala/private:common_attributes.bzl",
    "common_attrs",
    "common_attrs_for_plugin_bootstrapping",
    "implicit_deps",
    "launcher_template",
    "resolve_deps",
)
load("@io_bazel_rules_scala//scala/private:common_outputs.bzl", "common_outputs")
load(
    "@io_bazel_rules_scala//scala/private:coverage_replacements_provider.bzl",
    _coverage_replacements_provider = "coverage_replacements_provider",
)
load(
    "@io_bazel_rules_scala//specs2:specs2_junit.bzl",
    _specs2_junit_dependencies = "specs2_junit_dependencies",
)
load(
    "@io_bazel_rules_scala//scala:plusone.bzl",
    _collect_plus_one_deps_aspect = "collect_plus_one_deps_aspect",
)
load(
    "@io_bazel_rules_scala//scala/private:macros/scala_repositories.bzl",
    _scala_repositories = "scala_repositories",
)
load(
    "@io_bazel_rules_scala//scala/private:rules/scala_binary.bzl",
    _scala_binary = "scala_binary",
)
load(
    "@io_bazel_rules_scala//scala/private:rules/scala_doc.bzl",
    _scala_doc = "scala_doc",
)

_test_resolve_deps = {
    "_scala_toolchain": attr.label_list(
        default = [
            Label(
                "//external:io_bazel_rules_scala/dependency/scala/scala_library",
            ),
            Label(
                "//external:io_bazel_rules_scala/dependency/scalatest/scalatest",
            ),
        ],
        allow_files = False,
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

_library_attrs = {
    "main_class": attr.string(),
    "exports": attr.label_list(
        allow_files = False,
        aspects = [_coverage_replacements_provider.aspect],
    ),
}

_library_outputs = {}

_library_outputs.update(common_outputs)

_scala_library_attrs = {}

_scala_library_attrs.update(implicit_deps)

_scala_library_attrs.update(common_attrs)

_scala_library_attrs.update(_library_attrs)

_scala_library_attrs.update(resolve_deps)

scala_library = rule(
    attrs = _scala_library_attrs,
    fragments = ["java"],
    outputs = _library_outputs,
    toolchains = ["@io_bazel_rules_scala//scala:toolchain_type"],
    implementation = _scala_library_impl,
)

# the scala compiler plugin used for dependency analysis is compiled using `scala_library`.
# in order to avoid cyclic dependencies `scala_library_for_plugin_bootstrapping` was created for this purpose,
# which does not contain plugin related attributes, and thus avoids the cyclic dependency issue
_scala_library_for_plugin_bootstrapping_attrs = {}

_scala_library_for_plugin_bootstrapping_attrs.update(implicit_deps)

_scala_library_for_plugin_bootstrapping_attrs.update(_library_attrs)

_scala_library_for_plugin_bootstrapping_attrs.update(resolve_deps)

_scala_library_for_plugin_bootstrapping_attrs.update(
    common_attrs_for_plugin_bootstrapping,
)

scala_library_for_plugin_bootstrapping = rule(
    attrs = _scala_library_for_plugin_bootstrapping_attrs,
    fragments = ["java"],
    outputs = _library_outputs,
    toolchains = ["@io_bazel_rules_scala//scala:toolchain_type"],
    implementation = _scala_library_for_plugin_bootstrapping_impl,
)

_scala_macro_library_attrs = {
    "main_class": attr.string(),
    "exports": attr.label_list(allow_files = False),
}

_scala_macro_library_attrs.update(implicit_deps)

_scala_macro_library_attrs.update(common_attrs)

_scala_macro_library_attrs.update(_library_attrs)

_scala_macro_library_attrs.update(resolve_deps)

# Set unused_dependency_checker_mode default to off for scala_macro_library
_scala_macro_library_attrs["unused_dependency_checker_mode"] = attr.string(
    default = "off",
    values = [
        "warn",
        "error",
        "off",
        "",
    ],
    mandatory = False,
)

scala_macro_library = rule(
    attrs = _scala_macro_library_attrs,
    fragments = ["java"],
    outputs = common_outputs,
    toolchains = ["@io_bazel_rules_scala//scala:toolchain_type"],
    implementation = _scala_macro_library_impl,
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

_scala_test_attrs.update(_test_resolve_deps)

scala_test = rule(
    attrs = _scala_test_attrs,
    executable = True,
    fragments = ["java"],
    outputs = common_outputs,
    test = True,
    toolchains = ["@io_bazel_rules_scala//scala:toolchain_type"],
    implementation = _scala_test_impl,
)

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

def _sanitize_string_for_usage(s):
    res_array = []
    for idx in range(len(s)):
        c = s[idx]
        if c.isalnum() or c == ".":
            res_array.append(c)
        else:
            res_array.append("_")
    return "".join(res_array)

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
        n = ("%s_%s" % (name, i)) if use_short_names else ("%s_test_suite_%s" % (name, _sanitize_string_for_usage(test_file)))
        scala_test(
            name = n,
            srcs = [test_file],
            visibility = visibility,
            unused_dependency_checker_mode = "off",
            **kwargs
        )
        ts.append(n)
    native.test_suite(name = name, tests = ts, visibility = visibility)

# Scala library suite generates a series of scala libraries
# then it depends on them with a meta one which exports all the sub targets
def scala_library_suite(
        name,
        srcs = [],
        exports = [],
        visibility = None,
        **kwargs):
    ts = []
    for src_file in srcs:
        n = "%s_lib_%s" % (name, _sanitize_string_for_usage(src_file))
        scala_library(
            name = n,
            srcs = [src_file],
            visibility = visibility,
            exports = exports,
            unused_dependency_checker_mode = "off",
            **kwargs
        )
        ts.append(n)
    scala_library(
        name = name,
        visibility = visibility,
        exports = exports + ts,
        deps = ts,
    )

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

def scala_specs2_junit_test(name, **kwargs):
    scala_junit_test(
        name = name,
        deps = _specs2_junit_dependencies() + kwargs.pop("deps", []),
        unused_dependency_checker_ignored_targets =
            _specs2_junit_dependencies() + kwargs.pop("unused_dependency_checker_ignored_targets", []),
        suite_label = Label(
            "//src/java/io/bazel/rulesscala/specs2:specs2_test_discovery",
        ),
        suite_class = "io.bazel.rulesscala.specs2.Specs2DiscoveredTestSuite",
        **kwargs
    )

scala_binary = _scala_binary

scala_doc = _scala_doc

scala_repositories = _scala_repositories
