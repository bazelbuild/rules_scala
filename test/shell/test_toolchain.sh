# shellcheck source=./test_runner.sh
dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
. "${dir}"/test_runner.sh
. "${dir}"/test_helper.sh
runner=$(get_test_runner "${1:-local}")

test_scalaopts_from_scala_toolchain() {
  action_should_fail build --extra_toolchains="//test_expect_failure/scalacopts_from_toolchain:failing_scala_toolchain" //test_expect_failure/scalacopts_from_toolchain:failing_build
}

java_toolchain_javacopts_are_used(){
  action_should_fail_with_message \
    "invalid flag: -InvalidFlag" \
    build --javacopt="-InvalidFlag" \
      --verbose_failures //test_expect_failure/compilers_javac_opts:can_configure_jvm_flags_for_javac_via_javacopts
}

java_toolchain_javacopts_can_be_overridden(){
  action_should_fail_with_message \
    "invalid target release: InvalidTarget" \
    build \
      --verbose_failures //test_expect_failure/compilers_javac_opts:can_override_default_toolchain_flags_for_javac_via_javacopts
}

$runner test_scalaopts_from_scala_toolchain
$runner java_toolchain_javacopts_are_used
$runner java_toolchain_javacopts_can_be_overridden
