#!/usr/bin/env bash

set -e

md5_util() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        _md5_util="md5"
    else
        _md5_util="md5sum"
    fi
    echo "$_md5_util"
}

non_deploy_jar_md5_sum() {
    find bazel-bin/test -name "*.jar" ! -name "*_deploy.jar" | xargs -n 1 -P 5 $(md5_util) | sort
}

test_build_is_identical() {
    bazel build test/...
    non_deploy_jar_md5_sum > hash1
    bazel clean
    sleep 2 # to make sure that if timestamps slip in we get different ones
    bazel build --disk_cache /tmp/$RANDOM test/...
    non_deploy_jar_md5_sum > hash2
    diff hash1 hash2
}

dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
# shellcheck source=./test_runner.sh
. "${dir}"/test_runner.sh
runner=$(get_test_runner "${1:-local}")


# This test is last/separate since it compares the current outputs to new ones to make sure they're identical
# If it runs before some of the above (like jmh) the "current" output in CI might be too close in time to the "new" one
# The test also adds sleep by itself but it's best if it's last
$runner test_build_is_identical
