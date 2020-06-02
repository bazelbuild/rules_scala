# shellcheck source=./test_runner.sh
dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
. "${dir}"/test_runner.sh
. "${dir}"/test_helper.sh
runner=$(get_test_runner "${1:-local}")

test_scala_jvm_flags_on_target_overrides_toolchain_passes() {
  bazel test --extra_toolchains="//manual_test/scala_test_jvm_flags:failing_scala_toolchain" //manual_test/scala_test_jvm_flags:empty_overriding_test
}

test_scala_jvm_flags_from_scala_toolchain_passes() {
  bazel test --extra_toolchains="//manual_test/scala_test_jvm_flags:passing_scala_toolchain" //manual_test/scala_test_jvm_flags:empty_test
}

test_scala_jvm_flags_from_scala_toolchain_fails() {
  action_should_fail test --extra_toolchains="//test_expect_failure/scala_test_jvm_flags:failing_scala_toolchain" //test_expect_failure/scala_test_jvm_flags:empty_test
}

test_scala_library_with_scalacopts_containg_comma() {
  bazel build '//test_expect_failure/scalacopts:A'
}

$runner test_scala_jvm_flags_on_target_overrides_toolchain_passes
$runner test_scala_jvm_flags_from_scala_toolchain_passes
$runner test_scala_jvm_flags_from_scala_toolchain_fails
#$runner test_scala_library_with_scalacopts_containg_comma