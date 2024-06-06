# shellcheck source=./test_runner.sh
dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
. "${dir}"/test_runner.sh
. "${dir}"/test_helper.sh
runner=$(get_test_runner "${1:-local}")

cd test_cross_build

function test_cross_build() {
  bazel test //...
  bazel clean
  bazel shutdown;
}

$runner test_cross_build
