#!/usr/bin/env bash

set -e

if ! bazel_loc="$(type -p 'bazel')" || [[ -z "$bazel_loc" ]]; then
  export PATH="$(cd "$(dirname "$0")"; pwd)"/tools:$PATH
  echo 'Using ./tools/bazel directly for bazel calls'
fi

md5_util() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        _md5_util="md5"
    else
        _md5_util="md5sum"
    fi
    echo "$_md5_util"
}

non_deploy_jar_md5_sum() {
    find bazel-bin/test -name "*.jar" ! -name "*_deploy.jar" ! -path 'bazel-bin/test/jmh/*' | xargs -n 1 -P 5 $(md5_util) | sort
}

test_build_is_identical() {
    bazel build test/...
    # Also build instrumented jars.
    bazel build --collect_code_coverage -- //test/coverage/...
    non_deploy_jar_md5_sum > hash1
    bazel clean
    sleep 10 # to make sure that if timestamps slip in we get different ones
    random_dir=/tmp/$RANDOM
    bazel build --disk_cache $random_dir test/...
    bazel build --disk_cache $random_dir --collect_code_coverage -- //test/coverage/...
    non_deploy_jar_md5_sum > hash2
    diff hash1 hash2
}

test_dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/test/shell
# shellcheck source=./test_runner.sh
. "${test_dir}"/test_runner.sh
runner=$(get_test_runner "${1:-local}")


# This test is last/separate since it compares the current outputs to new ones to make sure they're identical
# If it runs before some of the above (like jmh) the "current" output in CI might be too close in time to the "new" one
# The test also adds sleep by itself but it's best if it's last
$runner test_build_is_identical
