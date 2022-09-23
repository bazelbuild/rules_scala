# shellcheck source=./test_runner.sh
dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
. "${dir}"/test_runner.sh
. "${dir}"/test_helper.sh
runner=$(get_test_runner "${1:-local}")

function test_inherited_environment() {
  a=b bazel test //test_expect_failure/scala_test_env_inherit:inherit_a
}

$runner test_inherited_environment