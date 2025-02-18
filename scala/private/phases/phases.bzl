"""
Re-expose all the phase APIs and built-in phases
"""

load(
    "//scala/private:phases/api.bzl",
    _extras_phases = "extras_phases",
    _run_phases = "run_phases",
)
load(
    "//scala/private:phases/phase_collect_jars.bzl",
    _phase_collect_jars_common = "phase_collect_jars_common",
    _phase_collect_jars_junit_test = "phase_collect_jars_junit_test",
    _phase_collect_jars_macro_library = "phase_collect_jars_macro_library",
    _phase_collect_jars_repl = "phase_collect_jars_repl",
    _phase_collect_jars_scalatest = "phase_collect_jars_scalatest",
)
load("//scala/private:phases/phase_collect_exports_jars.bzl", _phase_collect_exports_jars = "phase_collect_exports_jars")
load("//scala/private:phases/phase_collect_srcjars.bzl", _phase_collect_srcjars = "phase_collect_srcjars")
load(
    "//scala/private:phases/phase_compile.bzl",
    _phase_compile_binary = "phase_compile_binary",
    _phase_compile_common = "phase_compile_common",
    _phase_compile_junit_test = "phase_compile_junit_test",
    _phase_compile_library = "phase_compile_library",
    _phase_compile_library_for_plugin_bootstrapping = "phase_compile_library_for_plugin_bootstrapping",
    _phase_compile_repl = "phase_compile_repl",
    _phase_compile_scalatest = "phase_compile_scalatest",
)
load(
    "//scala/private:phases/phase_coverage.bzl",
    _phase_coverage_common = "phase_coverage_common",
    _phase_coverage_library = "phase_coverage_library",
)
load("//scala/private:phases/phase_coverage_runfiles.bzl", _phase_coverage_runfiles = "phase_coverage_runfiles")
load("//scala/private:phases/phase_declare_executable.bzl", _phase_declare_executable = "phase_declare_executable")
load("//scala/private:phases/phase_default_info.bzl", _phase_default_info = "phase_default_info")
load(
    "//scala/private:phases/phase_dependency.bzl",
    _phase_dependency_common = "phase_dependency_common",
    _phase_dependency_library_for_plugin_bootstrapping = "phase_dependency_library_for_plugin_bootstrapping",
)
load(
    "//scala/private:phases/phase_java_wrapper.bzl",
    _phase_java_wrapper_common = "phase_java_wrapper_common",
    _phase_java_wrapper_repl = "phase_java_wrapper_repl",
)
load("//scala/private:phases/phase_jvm_flags.bzl", _phase_jvm_flags = "phase_jvm_flags")
load("//scala/private:phases/phase_merge_jars.bzl", _phase_merge_jars = "phase_merge_jars")
load(
    "//scala/private:phases/phase_runfiles.bzl",
    _phase_runfiles_common = "phase_runfiles_common",
    _phase_runfiles_library = "phase_runfiles_library",
    _phase_runfiles_scalatest = "phase_runfiles_scalatest",
)
load("//scala/private:phases/phase_scalac_provider.bzl", _phase_scalac_provider = "phase_scalac_provider")
load("//scala/private:phases/phase_scalacopts.bzl", _phase_scalacopts = "phase_scalacopts")
load("//scala/private:phases/phase_scalafmt.bzl", _phase_scalafmt = "phase_scalafmt")
load(
    "//scala/private:phases/phase_scalainfo_provider.bzl",
    _phase_scalainfo_provider_macro = "phase_scalainfo_provider_macro",
    _phase_scalainfo_provider_non_macro = "phase_scalainfo_provider_non_macro",
)
load("//scala/private:phases/phase_semanticdb.bzl", _phase_semanticdb = "phase_semanticdb")
load("//scala/private:phases/phase_test_environment.bzl", _phase_test_environment = "phase_test_environment")
load(
    "//scala/private:phases/phase_write_executable.bzl",
    _phase_write_executable_common = "phase_write_executable_common",
    _phase_write_executable_junit_test = "phase_write_executable_junit_test",
    _phase_write_executable_repl = "phase_write_executable_repl",
    _phase_write_executable_scalatest = "phase_write_executable_scalatest",
)
load("//scala/private:phases/phase_write_manifest.bzl", _phase_write_manifest = "phase_write_manifest")

# API
run_phases = _run_phases
extras_phases = _extras_phases

# scalac_provider
phase_scalac_provider = _phase_scalac_provider

# scalainfo_provider
phase_scalainfo_provider_macro = _phase_scalainfo_provider_macro
phase_scalainfo_provider_non_macro = _phase_scalainfo_provider_non_macro

# collect_srcjars
phase_collect_srcjars = _phase_collect_srcjars

# collect_exports_jars
phase_collect_exports_jars = _phase_collect_exports_jars

# write_manifest
phase_write_manifest = _phase_write_manifest

# dependency
phase_dependency_common = _phase_dependency_common
phase_dependency_library_for_plugin_bootstrapping = _phase_dependency_library_for_plugin_bootstrapping

# declare_executable
phase_declare_executable = _phase_declare_executable

# merge_jars
phase_merge_jars = _phase_merge_jars

# jvm_flags
phase_jvm_flags = _phase_jvm_flags

# scalacopts
phase_scalacopts = _phase_scalacopts

# coverage
phase_coverage_library = _phase_coverage_library
phase_coverage_common = _phase_coverage_common

# coverage_runfiles
phase_coverage_runfiles = _phase_coverage_runfiles

# write_executable
phase_write_executable_scalatest = _phase_write_executable_scalatest
phase_write_executable_repl = _phase_write_executable_repl
phase_write_executable_junit_test = _phase_write_executable_junit_test
phase_write_executable_common = _phase_write_executable_common

# java_wrapper
phase_java_wrapper_repl = _phase_java_wrapper_repl
phase_java_wrapper_common = _phase_java_wrapper_common

# collect_jars
phase_collect_jars_scalatest = _phase_collect_jars_scalatest
phase_collect_jars_repl = _phase_collect_jars_repl
phase_collect_jars_macro_library = _phase_collect_jars_macro_library
phase_collect_jars_junit_test = _phase_collect_jars_junit_test
phase_collect_jars_common = _phase_collect_jars_common

# compile
phase_compile_binary = _phase_compile_binary
phase_compile_library = _phase_compile_library
phase_compile_library_for_plugin_bootstrapping = _phase_compile_library_for_plugin_bootstrapping
phase_compile_junit_test = _phase_compile_junit_test
phase_compile_repl = _phase_compile_repl
phase_compile_scalatest = _phase_compile_scalatest
phase_compile_common = _phase_compile_common

# runfiles
phase_runfiles_library = _phase_runfiles_library
phase_runfiles_scalatest = _phase_runfiles_scalatest
phase_runfiles_common = _phase_runfiles_common

# default_info
phase_default_info = _phase_default_info

# test_environment
phase_test_environment = _phase_test_environment

# scalafmt
phase_scalafmt = _phase_scalafmt

# semanticdb
phase_semanticdb = _phase_semanticdb
