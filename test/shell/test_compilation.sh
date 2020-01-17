# shellcheck source=./test_runner.sh
dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
. "${dir}"/test_runner.sh
. "${dir}"/test_helper.sh
runner=$(get_test_runner "${1:-local}")

test_compilation_succeeds_with_plus_one_deps_on() {
  bazel build --extra_toolchains=//test_expect_failure/plus_one_deps:plus_one_deps //test_expect_failure/plus_one_deps/internal_deps:a
}

test_compilation_fails_with_plus_one_deps_undefined() {
  action_should_fail build //test_expect_failure/plus_one_deps/internal_deps:a
}

test_compilation_succeeds_with_plus_one_deps_on_for_external_deps() {
  bazel build --extra_toolchains="//test_expect_failure/plus_one_deps:plus_one_deps" //test_expect_failure/plus_one_deps/external_deps:a
}

test_compilation_succeeds_with_plus_one_deps_on_also_for_exports_of_deps() {
  bazel build --extra_toolchains="//test_expect_failure/plus_one_deps:plus_one_deps" //test_expect_failure/plus_one_deps/exports_of_deps/...
}

test_compilation_succeeds_with_plus_one_deps_on_also_for_deps_of_exports() {
  bazel build --extra_toolchains="//test_expect_failure/plus_one_deps:plus_one_deps" //test_expect_failure/plus_one_deps/deps_of_exports/...
}

$runner test_compilation_succeeds_with_plus_one_deps_on
$runner test_compilation_fails_with_plus_one_deps_undefined
$runner test_compilation_succeeds_with_plus_one_deps_on_for_external_deps
$runner test_compilation_succeeds_with_plus_one_deps_on_also_for_exports_of_deps
$runner test_compilation_succeeds_with_plus_one_deps_on_also_for_deps_of_exports
