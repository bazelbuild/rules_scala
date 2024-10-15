# shellcheck source=./test_runner.sh
dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
. "${dir}"/test_runner.sh
. "${dir}"/test_helper.sh
runner=$(get_test_runner "${1:-local}")

SCALA_VERSION="${SCALA_VERSION:-2.12.19}"

test_coverage_on() {
    bazel coverage \
        --repo_env="SCALA_VERSION=${SCALA_VERSION}" \
        //test/coverage_specs2_with_junit:test-specs2-with-junit
    diff test/coverage_specs2_with_junit/expected-coverage.dat $(bazel info bazel-testlogs)/test/coverage_specs2_with_junit/test-specs2-with-junit/coverage.dat
}

test_coverage_includes_test_targets() {
    bazel coverage \
        --repo_env="SCALA_VERSION=${SCALA_VERSION}" \
        --instrument_test_targets=True \
        //test/coverage_specs2_with_junit:test-specs2-with-junit
    grep -q "SF:test/coverage_specs2_with_junit/TestWithSpecs2WithJUnit.scala" $(bazel info bazel-testlogs)/test/coverage_specs2_with_junit/test-specs2-with-junit/coverage.dat
}

$runner test_coverage_on
$runner test_coverage_includes_test_targets
