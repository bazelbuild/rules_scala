"""
Re-expose all the phase APIs and built-in phases
"""

load(
    "@io_bazel_rules_scala//scala/private:phases/api.bzl",
    _extras_phases = "extras_phases",
    _run_phases = "run_phases",
)
load(
    "@io_bazel_rules_scala//scala/private:phases/phase_write_executable.bzl",
    _phase_common_write_executable = "phase_common_write_executable",
    _phase_junit_test_write_executable = "phase_junit_test_write_executable",
    _phase_repl_write_executable = "phase_repl_write_executable",
    _phase_scalatest_write_executable = "phase_scalatest_write_executable",
)
load(
    "@io_bazel_rules_scala//scala/private:phases/phase_java_wrapper.bzl",
    _phase_common_java_wrapper = "phase_common_java_wrapper",
    _phase_repl_java_wrapper = "phase_repl_java_wrapper",
)
load(
    "@io_bazel_rules_scala//scala/private:phases/phase_collect_jars.bzl",
    _phase_common_collect_jars = "phase_common_collect_jars",
    _phase_junit_test_collect_jars = "phase_junit_test_collect_jars",
    _phase_library_for_plugin_bootstrapping_collect_jars = "phase_library_for_plugin_bootstrapping_collect_jars",
    _phase_macro_library_collect_jars = "phase_macro_library_collect_jars",
    _phase_repl_collect_jars = "phase_repl_collect_jars",
    _phase_scalatest_collect_jars = "phase_scalatest_collect_jars",
)
load(
    "@io_bazel_rules_scala//scala/private:phases/phase_compile.bzl",
    _phase_binary_compile = "phase_binary_compile",
    _phase_common_compile = "phase_common_compile",
    _phase_junit_test_compile = "phase_junit_test_compile",
    _phase_library_compile = "phase_library_compile",
    _phase_library_for_plugin_bootstrapping_compile = "phase_library_for_plugin_bootstrapping_compile",
    _phase_macro_library_compile = "phase_macro_library_compile",
    _phase_repl_compile = "phase_repl_compile",
    _phase_scalatest_compile = "phase_scalatest_compile",
)
load(
    "@io_bazel_rules_scala//scala/private:phases/phase_scala_provider.bzl",
    _phase_common_scala_provider = "phase_common_scala_provider",
    _phase_library_scala_provider = "phase_library_scala_provider",
)
load(
    "@io_bazel_rules_scala//scala/private:phases/phase_runfiles.bzl",
    _phase_common_runfiles = "phase_common_runfiles",
    _phase_library_runfiles = "phase_library_runfiles",
    _phase_scalatest_runfiles = "phase_scalatest_runfiles",
)
load(
    "@io_bazel_rules_scala//scala/private:phases/phase_final.bzl",
    _phase_binary_final = "phase_binary_final",
    _phase_library_final = "phase_library_final",
    _phase_scalatest_final = "phase_scalatest_final",
)
load("@io_bazel_rules_scala//scala/private:phases/phase_scalac_provider.bzl", _phase_scalac_provider = "phase_scalac_provider")
load("@io_bazel_rules_scala//scala/private:phases/phase_write_manifest.bzl", _phase_write_manifest = "phase_write_manifest")
load("@io_bazel_rules_scala//scala/private:phases/phase_collect_srcjars.bzl", _phase_collect_srcjars = "phase_collect_srcjars")
load("@io_bazel_rules_scala//scala/private:phases/phase_collect_exports_jars.bzl", _phase_collect_exports_jars = "phase_collect_exports_jars")
load("@io_bazel_rules_scala//scala/private:phases/phase_unused_deps_checker.bzl", _phase_unused_deps_checker = "phase_unused_deps_checker")
load("@io_bazel_rules_scala//scala/private:phases/phase_declare_executable.bzl", _phase_declare_executable = "phase_declare_executable")
load("@io_bazel_rules_scala//scala/private:phases/phase_merge_jars.bzl", _phase_merge_jars = "phase_merge_jars")
load("@io_bazel_rules_scala//scala/private:phases/phase_jvm_flags.bzl", _phase_jvm_flags = "phase_jvm_flags")
load("@io_bazel_rules_scala//scala/private:phases/phase_coverage_runfiles.bzl", _phase_coverage_runfiles = "phase_coverage_runfiles")

# API
run_phases = _run_phases
extras_phases = _extras_phases

# scalac_provider
phase_scalac_provider = _phase_scalac_provider

# collect_srcjars
phase_collect_srcjars = _phase_collect_srcjars

# collect_exports_jars
phase_collect_exports_jars = _phase_collect_exports_jars

# write_manifest
phase_write_manifest = _phase_write_manifest

# unused_deps_checker
phase_unused_deps_checker = _phase_unused_deps_checker

# declare_executable
phase_declare_executable = _phase_declare_executable

# merge_jars
phase_merge_jars = _phase_merge_jars

# jvm_flags
phase_jvm_flags = _phase_jvm_flags

# coverage_runfiles
phase_coverage_runfiles = _phase_coverage_runfiles

# write_executable
phase_scalatest_write_executable = _phase_scalatest_write_executable
phase_repl_write_executable = _phase_repl_write_executable
phase_junit_test_write_executable = _phase_junit_test_write_executable
phase_common_write_executable = _phase_common_write_executable

# java_wrapper
phase_repl_java_wrapper = _phase_repl_java_wrapper
phase_common_java_wrapper = _phase_common_java_wrapper

# collect_jars
phase_scalatest_collect_jars = _phase_scalatest_collect_jars
phase_repl_collect_jars = _phase_repl_collect_jars
phase_macro_library_collect_jars = _phase_macro_library_collect_jars
phase_junit_test_collect_jars = _phase_junit_test_collect_jars
phase_library_for_plugin_bootstrapping_collect_jars = _phase_library_for_plugin_bootstrapping_collect_jars
phase_common_collect_jars = _phase_common_collect_jars

# compile
phase_binary_compile = _phase_binary_compile
phase_library_compile = _phase_library_compile
phase_library_for_plugin_bootstrapping_compile = _phase_library_for_plugin_bootstrapping_compile
phase_macro_library_compile = _phase_macro_library_compile
phase_junit_test_compile = _phase_junit_test_compile
phase_repl_compile = _phase_repl_compile
phase_scalatest_compile = _phase_scalatest_compile
phase_common_compile = _phase_common_compile

# scala_provider
phase_library_scala_provider = _phase_library_scala_provider
phase_common_scala_provider = _phase_common_scala_provider

# runfiles
phase_library_runfiles = _phase_library_runfiles
phase_scalatest_runfiles = _phase_scalatest_runfiles
phase_common_runfiles = _phase_common_runfiles

# final
phase_binary_final = _phase_binary_final
phase_library_final = _phase_library_final
phase_scalatest_final = _phase_scalatest_final
