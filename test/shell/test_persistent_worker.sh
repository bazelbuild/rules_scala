#!/usr/bin/env bash

# shellcheck source=./test_runner.sh

dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
. "${dir}"/test_runner.sh
. "${dir}"/test_helper.sh
runner=$(get_test_runner "${1:-local}")

PERSISTENT_WORKER_FLAGS=("--strategy=Scalac=worker")

if ! is_windows; then
  #Bazel sandboxing is not currently implemented in windows 
  PERSISTENT_WORKER_FLAGS+=("--worker_sandboxing")
fi

check_persistent_worker_failure() {
  local unhandled_error_pattern='---8<---8<---'
  output="$(bazel "$@" 2>&1)"
  [[ ! "$output" =~ $unhandled_error_pattern ]]
}

test_persistent_worker_success() {
  # shellcheck disable=SC2086
  bazel build //test:ScalaBinary "${PERSISTENT_WORKER_FLAGS[@]}"
}

test_persistent_worker_failure() {
  action_should_fail \
    build //test_expect_failure/diagnostics_reporter:error_file \
    "${PERSISTENT_WORKER_FLAGS[@]}"
}

test_persistent_worker_handles_exception_in_macro_invocation() {
  local command=(
    build //test_expect_failure/scalac_exceptions:bad_macro_invocation
    "${PERSISTENT_WORKER_FLAGS[@]}"
  )
  local output=''
  local msg=(
    'Scalac persistent worker does not handle uncaught error'
    'in macro expansion.'
  )
  msg="${msg[*]}"

  if ! check_persistent_worker_failure "${command[@]}"; then
    echo "$output"
    echo -e "${RED} ${msg}${NC}"
    exit 1
  fi

  assert_matches 'Build failure during macro expansion' "$output" "$msg"
}

test_persistent_worker_handles_stack_overflow_exception() {
  local command=(
    build
    //test_expect_failure/scalac_exceptions:stack_overflow_macro_invocation
    "${PERSISTENT_WORKER_FLAGS[@]}"
  )
  local msg=(
    'Scalac persistent worker does not handle StackOverflowError'
    'in macro expansion.'
  )
  msg="${msg[*]}"

  if ! check_persistent_worker_failure "${command[@]}"; then
    echo "$output"
    echo -e "${RED} ${msg}${NC}"
    exit 1
  fi

  assert_matches 'Build failure with StackOverflowError' "$output" "$msg"
}

$runner test_persistent_worker_success
$runner test_persistent_worker_failure
$runner test_persistent_worker_handles_exception_in_macro_invocation
$runner test_persistent_worker_handles_stack_overflow_exception
