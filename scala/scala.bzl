load(
    "@io_bazel_rules_scala//specs2:specs2_junit.bzl",
    _specs2_junit_dependencies = "specs2_junit_dependencies",
)
load(
    "@io_bazel_rules_scala//scala/private:rules/scala_binary.bzl",
    _uniscala_scala_binary = "scala_binary",
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
    _uniscala_scala_library = "scala_library",
    _uniscala_scala_library_for_plugin_bootstrapping = "scala_library_for_plugin_bootstrapping",
    _uniscala_scala_library_suite = "scala_library_suite",
    _uniscala_scala_macro_library = "scala_macro_library",
)
load(
    "@io_bazel_rules_scala//scala/private:rules/scala_repl.bzl",
    _uniscala_scala_repl = "scala_repl",
)
load(
    "@io_bazel_rules_scala//scala/private:rules/scala_test.bzl",
    _uniscala_scala_test = "scala_test",
    _uniscala_scala_test_suite = "scala_test_suite",
)
load(
    "@io_bazel_rules_scala_configuration//:configuration.bzl",
    _multiscala_enabled = "multiscala_enabled",
)
load(
    "//unstable/multiscala/private:macros/scala_binary.bzl",
    _multiscala_scala_binary = "scala_binary"
)
load(
    "//unstable/multiscala/private:macros/scala_library.bzl",
    _multiscala_scala_library = "scala_library"
)
load(
    "//unstable/multiscala/private:macros/scala_test.bzl",
    _multiscala_scala_test = "scala_test"
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

def _demux(uniscala, multiscala):
    return multiscala if _multiscala_enabled() else uniscala

# Re-export private rules for public consumption
scala_binary = _demux(_uniscala_scala_binary, _multiscala_scala_binary)
scala_library = _demux(_uniscala_scala_library, _multiscala_scala_library)
scala_test = _demux(_uniscala_scala_test, _multiscala_scala_test)

scala_doc = _scala_doc
scala_junit_test = _scala_junit_test
scala_library_for_plugin_bootstrapping = _uniscala_scala_library_for_plugin_bootstrapping
scala_library_suite = _uniscala_scala_library_suite
scala_macro_library = _uniscala_scala_macro_library
scala_repl = _uniscala_scala_repl
scala_test_suite = _uniscala_scala_test_suite

def scala_repositories(**kwargs):
    fail("please import scala_repositories from @io_bazel_rules_scala//scala:scala_repositories.bzl")
