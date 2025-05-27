#!/usr/bin/env bash
#
# Test helper functions for rules_scala integration tests.

set -euo pipefail

function is_windows() {
  [[ "${OSTYPE}" =~ msys* ]] || [[ "${OSTYPE}" =~ cygwin* ]]
}

function is_macos() {
  [[ "${OSTYPE}" =~ darwin* ]]
}

_expect_bazel_failure() {
  output="$(bazel "$@" 2>&1)"

  if [[ "$?" -eq 0 ]]; then
    echo "$output"
    echo -e "${RED} \"bazel $*\" should have failed but passed.$NC"
    exit 1
  fi
}

action_should_fail() {
  # runs the tests locally
  set +e
  local output=''

  _expect_bazel_failure "$@"

  if verbose_test_output; then
    echo "$output"
    echo -e "${GREEN} \"bazel $*\" failed as expected.$NC"
  fi
}

_expect_failure_with_messages() {
  local bazel_cmd="$1"
  shift
  local messages=()
  local expected_message=""

  while [[ "$#" -ne 0 ]]; do
    expected_message="$1"
    shift

    if [[ -z "$expected_message" ]]; then
      continue
    elif [[ ! "$output" =~ $expected_message ]]; then
      echo "${output}"
      echo -e \
        "${RED} '${bazel_cmd}' should have logged \"${expected_message}\".$NC"
      exit 1
    fi

    messages+=("$expected_message")
  done

  if verbose_test_output; then
    echo "$output"
    printf '%b\n' "${GREEN} ${bazel_cmd}' logged expected messages:"
    printf '   - "%s"\n' "${messages[@]}"
    printf '%b' "$NC"
  fi
}

test_expect_failure_with_message() {
  set +e

  local expected_message="$1"
  local command=('test' '--nocache_test_results' '--test_output=streamed')
  local output=''

  shift

  if [[ "$1" =~ --test_filter= ]]; then
    command+=("$1")
    shift
  fi
  command+=("$1")

  _expect_bazel_failure "${command[@]}"
  _expect_failure_with_messages "bazel ${command[*]}" "$expected_message"
  set -e
}

action_should_fail_with_message() {
  set +e
  local msg="$1"
  local output=''
  shift

  _expect_bazel_failure "$@"

  if [[ ! "$output" =~ $msg ]]; then
    echo "$output"
    echo -e "${RED} \"bazel $*\" should have failed with message \"$msg\" but did not.$NC"
    exit 1
  elif verbose_test_output; then
    echo "$output"
    echo -e \
      "${GREEN} \"bazel $*\" failed with expected message \"$msg\".$NC"
  fi
}

action_should_fail_without_message() {
  set +e
  local msg="$1"
  local output=''
  shift

  _expect_bazel_failure "$@"

  if [[ "$output" =~ $msg ]]; then
    echo "$output"
    echo -e "${RED} \"bazel $*\" should have failed without message \"$msg\".$NC"
    exit 1
  elif verbose_test_output; then
    echo "$output"
    echo -e \
      "${GREEN} \"bazel $TEST_ARG\" failed without message \"$msg\".$NC"
  fi
}

test_expect_failure_or_warning_on_missing_direct_deps_with_expected_message() {
  set +e

  local expected_messages=("$1")
  local test_target="$2"
  local args="${3:-}"
  local operator="${4:-eq}"
  local additional_expected_message="${5:-}"
  local command=('bazel' 'build' "${test_target}" $args)
  local error_message=(
    "bazel build of scala_library with missing direct deps should have failed."
  )
  local output=''
  local status_code=0

  if [[ "${operator}" != "eq" ]]; then
    error_message="${error_message/should/should not}"
  fi

  output="$("${command[@]}" 2>&1)"
  status_code=$?

  # This breaks with `[[ ]]` because it doesn't support string substitution for
  # the operator.
  if [ "${status_code}" "-${operator}" 0 ]; then
    echo "$output"
    echo -e "${RED} ${error_message}${NC}"
    exit 1
  fi

  if [[ -n "$additional_expected_message" ]]; then
    expected_messages+=("$additional_expected_message")
  fi
  _expect_failure_with_messages "bazel build ${test_target}" \
    "${expected_messages[@]}"
  set -e
}

test_scala_library_expect_failure_on_missing_direct_deps() {
  local dependency_target="$1"
  local test_target="$2"

  local expected_message="buildozer 'add deps $dependency_target' //$test_target"

  test_expect_failure_or_warning_on_missing_direct_deps_with_expected_message \
    "${expected_message}" \
    "$test_target" \
    "--extra_toolchains=//test/toolchains:high_level_transitive_deps_strict_deps_error"
}

jar_contains_files() {
  local arg=''

  for arg in "${@:2}"
  do
    if ! jar tf $1 | grep $arg; then
      return 1
    fi
  done
}

_print_error_msg() {
  printf '%b' "$RED"
  printf '%s\n' "$@"
  printf '%b' "$NC"
}

assert_matches() {
  local expected="$1"
  local actual="$2"
  local msg="${3:-Value did not match regular expression}"

  if [[ ! "$actual" =~ $expected ]]; then
    _print_error_msg "$msg" \
      "Expected: \"$expected\"" \
      "Actual:   \"$actual\""
    return 1
  elif verbose_test_output; then
    printf '%b' "$GREEN"
    printf ' %s\n' "Value matched regular expression:" \
      "Expected: \"$expected\"" \
      "Actual:   \"$actual\""
    printf '%b' "$NC"
  fi
}
