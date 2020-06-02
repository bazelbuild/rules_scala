# shellcheck source=./test_runner.sh
dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
. "${dir}"/test_runner.sh
. "${dir}"/test_helper.sh
runner=$(get_test_runner "${1:-local}")

test_scala_library_with_scalacopts_containg_comma() {
  bazel build '//test/scalacopts:A'
}

$runner test_scala_library_with_scalacopts_containg_comma