# shellcheck source=./test_runner.sh
dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
. "${dir}"/test_runner.sh
. "${dir}"/test_helper.sh
runner=$(get_test_runner "${1:-local}")

test_coverage_target_name_contains_equals_sign() {
    bazel coverage //test/coverage_filename_encoding:name-with-equals
    diff test/coverage_filename_encoding/expected-coverage.dat $(bazel info bazel-testlogs)/test/coverage_filename_encoding/name-with-equals/coverage.dat
}

$runner test_coverage_target_name_contains_equals_sign
