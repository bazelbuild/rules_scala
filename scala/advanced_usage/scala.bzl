"""
Re-expose the customizable rules
It is used only when you intend to add functionalities to existing default rules
"""

load(
    "@io_bazel_rules_scala//scala/private:rules/scala_binary.bzl",
    _make_scala_binary = "make_scala_binary",
)
load(
    "@io_bazel_rules_scala//scala/private:rules/scala_junit_test.bzl",
    _make_scala_junit_test = "make_scala_junit_test",
)
load(
    "@io_bazel_rules_scala//scala/private:rules/scala_library.bzl",
    _make_scala_library = "make_scala_library",
    _make_scala_library_for_plugin_bootstrapping = "make_scala_library_for_plugin_bootstrapping",
    _make_scala_macro_library = "make_scala_macro_library",
)
load(
    "@io_bazel_rules_scala//scala/private:rules/scala_repl.bzl",
    _make_scala_repl = "make_scala_repl",
)
load(
    "@io_bazel_rules_scala//scala/private:rules/scala_test.bzl",
    _make_scala_test = "make_scala_test",
)

make_scala_binary = _make_scala_binary
make_scala_library = _make_scala_library
make_scala_library_for_plugin_bootstrapping = _make_scala_library_for_plugin_bootstrapping
make_scala_macro_library = _make_scala_macro_library
make_scala_repl = _make_scala_repl
make_scala_junit_test = _make_scala_junit_test
make_scala_test = _make_scala_test
