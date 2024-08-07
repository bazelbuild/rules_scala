# shellcheck source=./test_runner.sh
dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
. "${dir}"/test_runner.sh
. "${dir}"/test_helper.sh
. "${dir}"/test_scalafmt_helper.sh
runner=$(get_test_runner "${1:-local}")

cd test_cross_build

function test_cross_build() {
  bazel test //...
  bazel clean
  bazel shutdown;
}

function test_scalafmt() {
  run_formatting scalafmt binary2 binary2
  run_formatting scalafmt binary3 binary3
  run_formatting scalafmt library2 library2
  run_formatting scalafmt library3 library3
  run_formatting scalafmt test2 test2
  run_formatting scalafmt test3 test3
}

$runner test_cross_build
$runner test_scalafmt
