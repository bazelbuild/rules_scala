#!/usr/bin/env bash
#
# Test helper functions for rules_scala integration tests.

function is_windows() {
  [[ "${OSTYPE}" =~ msys* ]] || [[ "${OSTYPE}" =~ cygwin* ]]
}

function is_macos() {
  [[ "${OSTYPE}" =~ darwin* ]]
}

action_should_fail() {
  # runs the tests locally
  set +e
  TEST_ARG=$@
  DUMMY=$(bazel $TEST_ARG)
  RESPONSE_CODE=$?
  if [ $RESPONSE_CODE -eq 0 ]; then
    echo -e "${RED} \"bazel $TEST_ARG\" should have failed but passed. $NC"
    exit -1
  else
    exit 0
  fi
}

_expect_failure_with_messages() {
  local bazel_cmd="$1"
  shift
  local expected_message=""

  while [[ "$#" -ne 0 ]]; do
    expected_message="$1"
    shift

    if [[ -n "$expected_message" && ! "$output" =~ $expected_message ]]; then
      echo ${output}
      echo "'${bazel_cmd}' should have logged \"${expected_message}\"."
      exit 1
    fi
  done
}

test_expect_failure_with_message() {
  set +e

  expected_message=$1
  test_filter=$2
  test_command=$3

  command="bazel test --nocache_test_results --test_output=streamed ${test_filter} ${test_command}"
  output=$(${command} 2>&1)

  _expect_failure_with_messages "bazel test ${test_command}" \
    "$expected_message" "$additional_expected_message"
  set -e
}

action_should_fail_with_message() {
  set +e
  MSG=$1
  TEST_ARG=${@:2}
  RES=$(bazel $TEST_ARG 2>&1)
  RESPONSE_CODE=$?
  if [ $RESPONSE_CODE -eq 0 ]; then
    echo $RES 
    echo -e "${RED} \"bazel $TEST_ARG\" should have failed but passed. $NC"
    exit 1
  elif [[ ! "$RES" =~ $MSG ]]; then
    echo $RES
    echo -e "${RED} \"bazel $TEST_ARG\" should have failed with message \"$MSG\" but did not. $NC"
    exit 1
  else
    exit 0
  fi
}

action_should_fail_without_message() {
  set +e
  MSG=$1
  TEST_ARG=${@:2}
  RES=$(bazel $TEST_ARG 2>&1)
  RESPONSE_CODE=$?
  if [ $RESPONSE_CODE -eq 0 ]; then
    echo $RES
    echo -e "${RED} \"bazel $TEST_ARG\" should have failed but passed. $NC"
    exit 1
  elif [[ "$RES" =~ $MSG ]]; then
    echo $RES
    echo -e "${RED} \"bazel $TEST_ARG\" should have failed with message not containing \"$MSG\" but it did. $NC"
    exit 1
  else
    exit 0
  fi
}

test_expect_failure_or_warning_on_missing_direct_deps_with_expected_message() {
  set +e

  expected_message=$1
  test_target=$2
  args=$3
  operator=${4:-"eq"}
  additional_expected_message=${5:-""}

  if [ "${operator}" = "eq" ]; then
    error_message="bazel build of scala_library with missing direct deps should have failed."
  else
    error_message="bazel build of scala_library with missing direct deps should not have failed."
  fi

  command="bazel build ${test_target} ${args}"

  output=$(${command} 2>&1)
  status_code=$?

  echo "$output"
  if [ ${status_code} -${operator} 0 ]; then
    echo ${error_message}
    exit 1
  fi

  _expect_failure_with_messages "bazel build ${test_target}" \
    "$expected_message" "$additional_expected_message"
  set -e
}

test_scala_library_expect_failure_on_missing_direct_deps() {
  dependenecy_target=$1
  test_target=$2

  local expected_message="buildozer 'add deps $dependenecy_target' //$test_target"

  test_expect_failure_or_warning_on_missing_direct_deps_with_expected_message "${expected_message}" $test_target "--extra_toolchains=//test/toolchains:high_level_transitive_deps_strict_deps_error"
}

jar_contains_files() {
  for arg in "${@:2}"
  do
    if ! jar tf $1 | grep $arg; then
      return 1
    fi
  done
}
