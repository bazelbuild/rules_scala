# Diagnostics Reporters Tests. Diagnostics definition based off the definition provided by the LSP

# shellcheck source=./test_runner.sh
dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
. "${dir}"/test_runner.sh
runner=$(get_test_runner "${1:-local}")

test_diagnostics_reporter() {
  bazel build --build_event_publish_all_actions -k --extra_toolchains="//test_expect_failure/diagnostics_reporter:diagnostics_reporter_toolchain" //test_expect_failure/diagnostics_reporter:all || true
  diagnostics_output="$(bazel info bazel-bin)/test_expect_failure/diagnostics_reporter"
  bazel run //test/diagnostics_reporter:diagnostics_reporter_test "$diagnostics_output"
}

test_diagnostics_reporter_with_semanticdb() {
  bazel build --build_event_publish_all_actions -k --extra_toolchains="//test_expect_failure/diagnostics_reporter:diagnostics_reporter_and_semanticdb_toolchain" //test_expect_failure/diagnostics_reporter:all || true
  diagnostics_output="$(bazel info bazel-bin)/test_expect_failure/diagnostics_reporter"
  bazel run //test/diagnostics_reporter:diagnostics_reporter_test "$diagnostics_output"
}

$runner test_diagnostics_reporter
$runner test_diagnostics_reporter_with_semanticdb