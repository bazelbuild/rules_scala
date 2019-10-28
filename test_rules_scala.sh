#!/usr/bin/env bash

set -e

if ! bazel_loc="$(type -p 'bazel')" || [[ -z "$bazel_loc" ]]; then
  export PATH="$(cd "$(dirname "$0")"; pwd)"/tools:$PATH
  echo 'Using ./tools/bazel directly for bazel calls'
fi

test_dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/test/shell
# shellcheck source=./test_runner.sh
. "${test_dir}"/test_runner.sh
runner=$(get_test_runner "${1:-local}")

$runner bazel build test/...
#$runner bazel build "test/... --all_incompatible_changes"
$runner bazel test test/...
$runner bazel test third_party/...
# UnusedDependencyChecker doesn't work with strict_java_deps
$runner bazel build "--strict_java_deps=ERROR -- test/... -test:UnusedDependencyChecker"
#$runner bazel build "--strict_java_deps=ERROR --all_incompatible_changes -- test/... -test:UnusedDependencyChecker"
$runner bazel test "--strict_java_deps=ERROR -- test/... -test:UnusedDependencyChecker"
$runner bazel build "test_expect_failure/missing_direct_deps/internal_deps/... --strict_java_deps=warn"
$runner bazel build //test_expect_failure/proto_source_root/... --strict_proto_deps=off
$runner bazel test //test/... --extra_toolchains="//test_expect_failure/plus_one_deps:plus_one_deps"
. "${test_dir}"/test_build_event_protocol.sh
. "${test_dir}"/test_compilation.sh
. "${test_dir}"/test_deps.sh
. "${test_dir}"/test_javac_jvm_flags.sh
. "${test_dir}"/test_junit.sh
. "${test_dir}"/test_misc.sh
. "${test_dir}"/test_phase.sh
. "${test_dir}"/test_scalafmt.sh
. "${test_dir}"/test_scala_binary.sh
. "${test_dir}"/test_scalac_jvm_flags.sh
. "${test_dir}"/test_scala_classpath.sh
. "${test_dir}"/test_scala_import_source_jar.sh
. "${test_dir}"/test_scala_jvm_flags.sh
. "${test_dir}"/test_scala_library_jar.sh
. "${test_dir}"/test_scala_library.sh
. "${test_dir}"/test_scala_specs2.sh
. "${test_dir}"/test_toolchain.sh
. "${test_dir}"/test_unused_dependency.sh
