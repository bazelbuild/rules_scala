#!/usr/bin/env bash
#
# Test to be run for manual verification of built jacocorunner.
#
# It first builds custom jacocorunner and then verifies it.

set -e

if ! bazel_loc="$(type -p 'bazel')" || [[ -z "$bazel_loc" ]]; then
  export PATH="$(cd "$(dirname "$0")"; pwd)"/tools:$PATH
  echo 'Using ./tools/bazel directly for bazel calls'
fi

root_dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/../../

test_dir=$root_dir/test/shell
. "${test_dir}"/test_runner.sh
. "${test_dir}"/test_helper.sh
runner=$(get_test_runner "${1:-local}")

test_coverage_with_local_jacocorunner() {
    bazel coverage --extra_toolchains="//manual_test/coverage_local_jacocorunner:local_jacocorunner_scala_toolchain" //test/coverage_scalatest:test-scalatest
    diff $root_dir/manual_test/coverage_local_jacocorunner/expected-coverage.dat $(bazel info bazel-testlogs)/test/coverage_scalatest/test-scalatest/coverage.dat
}

build_local_jacocorunner() {
    # Build for Bazel 6 (as this is the default Bazel version in the repo).
    $root_dir/scripts/build_jacocorunner/build_jacocorunner.sh 6
    cp /tmp/bazel_jacocorunner_build/JacocoCoverage_jarjar_deploy.jar $root_dir/manual_test/coverage_local_jacocorunner
}

build_local_jacocorunner
$runner test_coverage_with_local_jacocorunner
