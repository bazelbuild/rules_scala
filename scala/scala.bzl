load(
    "@io_bazel_rules_scala//specs2:specs2_junit.bzl",
    _specs2_junit_dependencies = "specs2_junit_dependencies",
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
    _make_scala_doc_rule = "make_scala_doc_rule",
    _scaladoc_intransitive_aspect = "scaladoc_intransitive_aspect",
)
load(
    "@io_bazel_rules_scala//scala/private:rules/scala_junit_test.bzl",
    _scala_junit_test = "scala_junit_test",
)
load(
    "@io_bazel_rules_scala//scala/private:rules/scala_library.bzl",
    _scala_library = "scala_library",
    _scala_library_for_plugin_bootstrapping = "scala_library_for_plugin_bootstrapping",
    _scala_library_suite = "scala_library_suite",
    _scala_macro_library = "scala_macro_library",
)
load(
    "@io_bazel_rules_scala//scala/private:rules/scala_repl.bzl",
    _scala_repl = "scala_repl",
)
load(
    "@io_bazel_rules_scala//scala/private:rules/scala_test.bzl",
    _scala_test = "scala_test",
    _scala_test_suite = "scala_test_suite",
)

def scala_specs2_junit_test(name, **kwargs):
    _scala_junit_test(
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

# Re-export private rules for public consumption
scala_binary = _scala_binary

# These are exported for enabling users to build scaladocs without transitive dependencies.
make_scala_doc_rule = _make_scala_doc_rule
scaladoc_intransitive_aspect = _scaladoc_intransitive_aspect
scala_doc = _make_scala_doc_rule()
scala_junit_test = _scala_junit_test
scala_library = _scala_library
scala_library_for_plugin_bootstrapping = _scala_library_for_plugin_bootstrapping
scala_library_suite = _scala_library_suite
scala_macro_library = _scala_macro_library
scala_repl = _scala_repl
scala_repositories = _scala_repositories
scala_test = _scala_test
scala_test_suite = _scala_test_suite
