# shellcheck source=./test_runner.sh
dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
. "${dir}"/test_runner.sh
. "${dir}"/test_helper.sh
. "${dir}"/test_scalafmt_helper.sh
runner=$(get_test_runner "${1:-local}")

test_scalafmt_binary() {
  run_formatting test/scalafmt binary encoding
}

test_scalafmt_library() {
  run_formatting test/scalafmt library encoding
}

test_scalafmt_test() {
  run_formatting test/scalafmt test test
}
test_custom_conf() {
  run_formatting test/scalafmt custom-conf custom-conf
}

$runner test_scalafmt_binary
$runner test_scalafmt_library
$runner test_scalafmt_test
$runner test_custom_conf
