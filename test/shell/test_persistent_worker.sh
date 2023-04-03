# shellcheck source=./test_runner.sh

dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
. "${dir}"/test_runner.sh
. "${dir}"/test_helper.sh
runner=$(get_test_runner "${1:-local}")

test_persistent_worker_handles_exception_in_macro_invocation() {
  bazel build //test_expect_failure/scalac_exceptions:bad_macro_invocation --strategy=Scalac=worker --worker_sandboxing 2>&1  | grep -q -- "---8<---8<---"
  RESPONSE_CODE=$?
  if [ $RESPONSE_CODE -ne 1 ]; then
    echo -e "${RED} Scalac persistent worker does not handle uncaught error in macro expansion. $NC"
    exit 1
  fi
}

$runner test_persistent_worker_handles_exception_in_macro_invocation