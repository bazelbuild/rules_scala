#!/usr/bin/env bash

set -euo pipefail

# shellcheck source=./test_runner.sh
dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
. "${dir}"/test_runner.sh
. "${dir}"/test_helper.sh
runner=$(get_test_runner "${1:-local}")

incorrect_macro_user_does_not_build() {
  (! bazel build //test/macros:incorrect-macro-user) 2>&1 |
    grep --fixed-strings 'Build failure during macro expansion. You may have declared a target containing a macro as a `scala_library` target instead of a `scala_macro_library` target'
}

correct_macro_user_builds() {
  bazel build //test/macros:correct-macro-user
}

macros_can_have_dependencies() {
  bazel build //test/macros:macro-with-dependencies-user
}

$runner incorrect_macro_user_does_not_build
$runner correct_macro_user_builds
$runner macros_can_have_dependencies
