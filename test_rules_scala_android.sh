#!/bin/bash

set -e

action_should_fail_with_message() {
    set +e
    MSG=$1
    TEST_ARG=${@:2}
    RES=$(bazel $TEST_ARG 2>&1)
    RESPONSE_CODE=$?
    echo $RES | grep -- "$MSG"
    GREP_RES=$?
    if [ $RESPONSE_CODE -eq 0 ]; then
        echo -e "${RED} \"bazel $TEST_ARG\" should have failed but passed. $NC"
        exit 1
    elif [ $GREP_RES -ne 0 ]; then
        echo -e "${RED} \"bazel $TEST_ARG\" should have failed with message \"$MSG\" but did not. $NC"
    else
        exit 0
    fi
}

test_scala_android_missing_manifest() {
    action_should_fail_with_message \
        "attribute manifest: manifest is required when resource_files are present" \
        build --verbose_failures //test_expect_failure/scala_android_library:missing_manifest
}

dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
# shellcheck source=./test_runner.sh
. "${dir}"/test_runner.sh
runner=$(get_test_runner "${1:-local}")

$runner bazel build test:ScalaAndroidLibrary
$runner bazel build test:ScalaAndroidBinary
$runner test_scala_android_missing_manifest
