# Diagnostics Reporters Tests. Diagnostics definition based off the definition provided by the LSP

# shellcheck source=./test_runner.sh
dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
. "${dir}"/test_runner.sh
. "${dir}"/test_helper.sh
runner=$(get_test_runner "${1:-local}")

build_target() {
  target=$1
  bazel build --build_event_publish_all_actions //test_expect_failure/diagnostics_reporter:"$target" || true
}

verify_output() {
  target=$1
  shift
  expected_outputs=$@
  diagnostics_output="$(bazel info execution_root)/bazel-out/darwin-fastbuild/bin/test_expect_failure/diagnostics_reporter/$target.diagnosticsproto"
  bazel run //test/diagnostics_reporter:verify_diagnostics_output "$diagnostics_output" "${expected_outputs[@]}"
}

verify_error_file() {
  build_target "error_file"
  local outputs=(1 5 2 6 0)
  verify_output "error_file" "${outputs[@]}"
}

verify_two_errors_file() {
  build_target "two_errors_file"
  outputs=(1 4 4 5 0 1 5 4 6 0)
  verify_output "two_errors_file" "${outputs[@]}"
}

verify_warning_file() {
  build_target "warning_file"
  outputs=(2 0 0 0 7)
  verify_output "warning_file" "${outputs[@]}"
}

verify_error_and_warning_file() {
  build_target "error_and_warning_file"
  outputs=(2 0 0 0 7 1 4 4 5 0)
  verify_output "error_and_warning_file" "${outputs[@]}"
}

verify_info_file() {
  build_target "info_file"
  outputs=(3 -1 -1 0 0)
  verify_output "info_file" "${outputs[@]}"
}

$runner verify_error_file
$runner verify_two_errors_file
$runner verify_warning_file
$runner verify_error_and_warning_file
$runner verify_info_file
