# shellcheck source=./test_runner.sh
dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
. "${dir}"/test_runner.sh
. "${dir}"/test_helper.sh
runner=$(get_test_runner "${1:-local}")

macros_can_have_dependencies() {
  bazel build //test/macros:macro-with-dependencies-user
}

$runner macros_can_have_dependencies
