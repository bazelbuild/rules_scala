load(
    "@io_bazel_rules_scala//specs2:specs2_junit.bzl",
    _specs2_junit_dependencies = "specs2_junit_dependencies",
)
load(
    "@io_bazel_rules_scala//scala/private:macros/scala_repositories.bzl",
    _scala_repositories = "scala_repositories",
)
load(
    "//3rdparty:workspace.bzl",
    _maven_dependencies = "maven_dependencies",
)
load(
    "@io_bazel_rules_scala//scala/private:rules/scala_binary.bzl",
    _scala_binary = "scala_binary",
)
load(
    "@io_bazel_rules_scala//scala/private:rules/scala_doc.bzl",
    _scala_doc = "scala_doc",
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
scala_doc = _scala_doc
scala_junit_test = _scala_junit_test
scala_library = _scala_library
scala_library_for_plugin_bootstrapping = _scala_library_for_plugin_bootstrapping
scala_library_suite = _scala_library_suite
scala_macro_library = _scala_macro_library
scala_repl = _scala_repl
scala_repositories = _scala_repositories
maven_dependencies = _maven_dependencies
scala_test = _scala_test
scala_test_suite = _scala_test_suite
