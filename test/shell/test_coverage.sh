# shellcheck source=./test_runner.sh
dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
. "${dir}"/test_runner.sh
. "${dir}"/test_helper.sh
runner=$(get_test_runner "${1:-local}")

test_coverage_on() {
    bazel coverage \
          --extra_toolchains="//scala:code_coverage_toolchain" \
          //test/coverage/...
    diff test/coverage/expected-coverage.dat $(bazel info bazel-testlogs)/test/coverage/test-all/coverage.dat
}

test_coverage_includes_test_targets() {
    bazel coverage \
          --extra_toolchains="//scala:code_coverage_toolchain" \
          --instrument_test_targets=True \
          //test/coverage/...
    grep -q "SF:test/coverage/TestAll.scala" $(bazel info bazel-testlogs)/test/coverage/test-all/coverage.dat
}

xmllint_test() {
  find -L ./bazel-testlogs -iname "*.xml" | xargs -n1 xmllint > /dev/null
}

$runner test_coverage_on
$runner test_coverage_includes_test_targets
