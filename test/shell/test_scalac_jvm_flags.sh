# shellcheck source=./test_runner.sh
dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
. "${dir}"/test_runner.sh
. "${dir}"/test_helper.sh
runner=$(get_test_runner "${1:-local}")

test_scalac_jvm_flags_on_target_overrides_toolchain_passes() {
  bazel build --extra_toolchains="//manual_test/scalac_jvm_opts:failing_scala_toolchain" //manual_test/scalac_jvm_opts:empty_overriding_build
}

test_scalac_jvm_flags_from_scala_toolchain_passes() {
  bazel build --extra_toolchains="//manual_test/scalac_jvm_opts:passing_scala_toolchain" //manual_test/scalac_jvm_opts:empty_build
}

test_scalac_jvm_flags_from_scala_toolchain_fails() {
  action_should_fail build --extra_toolchains="//test_expect_failure/scalac_jvm_opts:failing_scala_toolchain" //test_expect_failure/scalac_jvm_opts:empty_build
}

test_scalac_jvm_flags_work_with_scalapb() {
  bazel build --extra_toolchains="//manual_test/scalac_jvm_opts:passing_scala_toolchain" //manual_test/scalac_jvm_opts:proto
}

test_scalac_jvm_flags_are_configured(){
  action_should_fail build //test_expect_failure/compilers_jvm_flags:can_configure_jvm_flags_for_scalac
}

test_scalac_jvm_flags_are_expanded(){
  action_should_fail_with_message \
    "--made_up_flag_to_expand=test_expect_failure/compilers_jvm_flags/args.txt" \
    build --verbose_failures //test_expect_failure/compilers_jvm_flags:can_expand_jvm_flags_for_scalac
}

$runner test_scalac_jvm_flags_on_target_overrides_toolchain_passes
$runner test_scalac_jvm_flags_from_scala_toolchain_passes
$runner test_scalac_jvm_flags_from_scala_toolchain_fails
$runner test_scalac_jvm_flags_work_with_scalapb
$runner test_scalac_jvm_flags_are_configured
$runner test_scalac_jvm_flags_are_expanded
