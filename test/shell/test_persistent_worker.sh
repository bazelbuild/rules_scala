# shellcheck source=./test_runner.sh

dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
. "${dir}"/test_runner.sh
. "${dir}"/test_helper.sh
runner=$(get_test_runner "${1:-local}")

PERSISTENT_WORKER_FLAGS="--strategy=Scalac=worker --worker_sandboxing"

test_persistent_worker_success() {
  # shellcheck disable=SC2086
  bazel build //test:ScalaBinary $PERSISTENT_WORKER_FLAGS
}

test_persistent_worker_failure() {
  action_should_fail "build //test_expect_failure/diagnostics_reporter:error_file $PERSISTENT_WORKER_FLAGS"
}

test_persistent_worker_handles_exception_in_macro_invocation() {
  command="bazel build //test_expect_failure/scalac_exceptions:bad_macro_invocation $PERSISTENT_WORKER_FLAGS"
  output=$(${command} 2>&1)
  ! (echo "$output" | grep -q -- "---8<---8<---") && (echo "$output" | grep -q "Build failure during macro expansion")

  RESPONSE_CODE=$?
  if [ $RESPONSE_CODE -ne 0 ]; then
    echo -e "${RED} Scalac persistent worker does not handle uncaught error in macro expansion. $NC"
    exit 1
  fi
}

$runner test_persistent_worker_success
$runner test_persistent_worker_failure
$runner test_persistent_worker_handles_exception_in_macro_invocation