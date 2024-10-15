# shellcheck source=./test_runner.sh
dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
. "${dir}"/test_runner.sh
. "${dir}"/test_helper.sh
runner=$(get_test_runner "${1:-local}")

SCALA_VERSION="${SCALA_VERSION:-2.12.19}"

test_coverage_succeeds_resource_call() {
    bazel coverage \
        --repo_env="SCALA_VERSION=${SCALA_VERSION}" \
        --instrumentation_filter=^//test/coverage_scalatest_resources[:/] \
        //test/coverage_scalatest_resources/consumer:tests
    diff test/coverage_scalatest_resources/expected-coverage.dat $(bazel info bazel-testlogs)/test/coverage_scalatest_resources/consumer/tests/coverage.dat
}

test_coverage_includes_resource_test_targets() {
    bazel coverage \
        --repo_env="SCALA_VERSION=${SCALA_VERSION}" \
        --instrument_test_targets=True \
        //test/coverage_scalatest_resources/consumer:tests
    grep -q "SF:test/coverage_scalatest_resources/consumer/src/test/scala/com/example/consumer/ConsumerSpec.scala" $(bazel info bazel-testlogs)/test/coverage_scalatest_resources/consumer/tests/coverage.dat
}

$runner test_coverage_succeeds_resource_call
$runner test_coverage_includes_resource_test_targets
