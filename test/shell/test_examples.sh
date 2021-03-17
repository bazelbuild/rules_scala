# shellcheck source=./test_runner.sh
dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
. "${dir}"/test_runner.sh
. "${dir}"/test_helper.sh
runner=$(get_test_runner "${1:-local}")

function scalatest_repositories_example() {
  (cd examples/testing/scalatest_repositories; bazel test //...)
}

function specs2_junit_repositories_example() {
  (cd examples/testing/specs2_junit_repositories; bazel test //...)
}

function multi_framework_toolchain_example() {
  (cd examples/testing/multi_frameworks_toolchain; bazel test //...)
}

$runner scalatest_repositories_example
$runner specs2_junit_repositories_example
$runner multi_framework_toolchain_example
