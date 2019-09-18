# shellcheck source=./test_runner.sh
dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
. "${dir}"/test_runner.sh
. "${dir}"/test_helper.sh
runner=$(get_test_runner "${1:-local}")

javac_jvm_flags_are_configured(){
  action_should_fail build //test_expect_failure/compilers_jvm_flags:can_configure_jvm_flags_for_javac
}

javac_jvm_flags_via_javacopts_are_configured(){
  action_should_fail build //test_expect_failure/compilers_jvm_flags:can_configure_jvm_flags_for_javac_via_javacopts
}

javac_jvm_flags_are_expanded(){
  action_should_fail_with_message \
    "invalid flag: test_expect_failure/compilers_jvm_flags/args.txt" \
    build --verbose_failures //test_expect_failure/compilers_jvm_flags:can_expand_jvm_flags_for_javac
}

javac_jvm_flags_via_javacopts_are_expanded(){
  action_should_fail_with_message \
    "invalid flag: test_expect_failure/compilers_jvm_flags/args.txt" \
    build --verbose_failures //test_expect_failure/compilers_jvm_flags:can_expand_jvm_flags_for_javac_via_javacopts
}

$runner javac_jvm_flags_are_configured
$runner javac_jvm_flags_via_javacopts_are_configured
$runner javac_jvm_flags_are_expanded
$runner javac_jvm_flags_via_javacopts_are_expanded
