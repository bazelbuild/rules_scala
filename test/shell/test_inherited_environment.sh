# shellcheck source=./test_runner.sh
dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
. "${dir}"/test_runner.sh
. "${dir}"/test_helper.sh
runner=$(get_test_runner "${1:-local}")

function test_inherited_environment() {
  a=b bazel test //test_bazel_5_2/inherited_environment:a
}

$runner test_inherited_environment