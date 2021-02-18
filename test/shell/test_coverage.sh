# shellcheck source=./test_runner.sh
dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
. "${dir}"/test_runner.sh
. "${dir}"/test_helper.sh
runner=$(get_test_runner "${1:-local}")

test_coverage_on() {
    bazel coverage //test/coverage/...
    diff test/coverage/expected-coverage.dat $(bazel info bazel-testlogs)/test/coverage/test-all/coverage.dat
}

test_coverage_includes_test_targets() {
    bazel coverage \
          --instrument_test_targets=True \
          //test/coverage/...
    grep -q "SF:test/coverage/TestAll.scala" $(bazel info bazel-testlogs)/test/coverage/test-all/coverage.dat
}

$runner test_coverage_on
$runner test_coverage_includes_test_targets
