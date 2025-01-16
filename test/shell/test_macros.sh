# shellcheck source=./test_runner.sh
dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
. "${dir}"/test_runner.sh
. "${dir}"/test_helper.sh
runner=$(get_test_runner "${1:-local}")

incorrect_macro_user_does_not_build() {
  (! bazel build //test/macros:incorrect-macro-user) |&
    grep --fixed-strings 'java.lang.Exception: You may have declared a target containing a macro as a `scala_library` target instead of a `scala_macro_library` target.'
}

correct_macro_user_builds() {
  bazel build //test/macros:correct-macro-user
}

$runner incorrect_macro_user_does_not_build
$runner correct_macro_user_builds
