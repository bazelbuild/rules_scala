# shellcheck source=./test_runner.sh
dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
. "${dir}"/test_runner.sh
. "${dir}"/test_helper.sh
runner=$(get_test_runner "${1:-local}")

test_unused_dependency_checker_mode_from_scala_toolchain() {
  action_should_fail build --extra_toolchains="//test_expect_failure/unused_dependency_checker:failing_scala_toolchain" //test_expect_failure/unused_dependency_checker:toolchain_failing_build
}

test_unused_dependency_checker_mode_set_in_rule() {
  action_should_fail build //test_expect_failure/unused_dependency_checker:failing_build
}

test_unused_dependency_checker_mode_override_toolchain() {
  bazel build --extra_toolchains="//test_expect_failure/unused_dependency_checker:failing_scala_toolchain" //test_expect_failure/unused_dependency_checker:toolchain_override
}

test_succeeds_with_warning() {
  cmd=$1
  expected=$2

  local output
  output=$($cmd 2>&1)

  if [ $? -ne 0 ]; then
    echo "Target with unused dependency failed to build with status $?"
    echo "$output"
    exit 1
  fi

  echo "$output" | grep "$expected"
  if [ $? -ne 0 ]; then
    echo "Expected output:[$output] to contain [$expected]"
    exit 1
  fi
}

test_unused_dependency_checker_mode_warn() {
  # this is a hack to invalidate the cache, so that the target actually gets built and outputs warnings.
  bazel build \
    --extra_toolchains=//test/toolchains:high_level_transitive_deps_strict_deps_warn \
    //test:UnusedDependencyCheckerWarn

  test_succeeds_with_warning \
    "bazel build --extra_toolchains=//test/toolchains:high_level_direct_deps //test:UnusedDependencyCheckerWarn" \
    "warning: Target '//test:UnusedLib' is specified as a dependency to //test:UnusedDependencyCheckerWarn but isn't used, please remove it from the deps."
}

test_unused_dependency_fails_even_if_also_exists_in_plus_one_deps() {
  action_should_fail build --extra_toolchains="//test_expect_failure/plus_one_deps:plus_one_deps_with_unused_error" //test_expect_failure/plus_one_deps/with_unused_deps:a
}

test_plus_one_ast_analyzer_unused_deps_error() {
  action_should_fail build --extra_toolchains="//test/toolchains:ast_plus_one_deps_unused_deps_error" //test_expect_failure/plus_one_deps/with_unused_deps:a
}

test_plus_one_ast_analyzer_unused_deps_strict_deps_error() {
  action_should_fail build --extra_toolchains="//scala:minimal_direct_source_deps" //test_expect_failure/plus_one_deps/with_unused_deps:a
}

test_plus_one_ast_analyzer_unused_deps_warn() {
  test_succeeds_with_warning \
    "bazel build --extra_toolchains=//test/toolchains:ast_plus_one_deps_unused_deps_warn //test_expect_failure/plus_one_deps/with_unused_deps:a" \
    "warning: Target '//test_expect_failure/plus_one_deps/with_unused_deps:c' is specified as a dependency to //test_expect_failure/plus_one_deps/with_unused_deps:a but isn't used, please remove it from the deps."
}

test_plus_one_ast_analyzer_unused_deps_scala_test() {
  # We should not emit an unuse dep warning for scalatest library in a scala_test rule
  # even when the rule does not directly depend on scalatest. As scalatest is built into
  # the scala_test library.
  bazel build --extra_toolchains="//test/toolchains:ast_plus_one_deps_unused_deps_error" //test/scala_test:b
}

test_unused_deps_filter_excluded_target() {
  bazel build //test_expect_failure/unused_dependency_checker/filtering:a \
    --extra_toolchains=//test_expect_failure/unused_dependency_checker/filtering:plus_one_unused_deps_filter
}

test_unused_deps_filter_included_target() {
  local test_target="//test_expect_failure/unused_dependency_checker/filtering:b"
  local expected_message="buildozer 'remove deps @com_google_guava_guava_21_0//:com_google_guava_guava_21_0' ${test_target}"

  test_expect_failure_or_warning_on_missing_direct_deps_with_expected_message \
    "${expected_message}" ${test_target} \
    "--extra_toolchains=//test_expect_failure/unused_dependency_checker/filtering:plus_one_unused_deps_filter" \
    "eq"
}

$runner test_unused_dependency_checker_mode_from_scala_toolchain
$runner test_unused_dependency_checker_mode_set_in_rule
$runner test_unused_dependency_checker_mode_override_toolchain
$runner test_unused_dependency_checker_mode_warn
$runner test_unused_dependency_fails_even_if_also_exists_in_plus_one_deps
$runner test_plus_one_ast_analyzer_unused_deps_error
$runner test_plus_one_ast_analyzer_unused_deps_strict_deps_error
$runner test_plus_one_ast_analyzer_unused_deps_warn
$runner test_plus_one_ast_analyzer_unused_deps_scala_test
$runner test_unused_deps_filter_excluded_target
$runner test_unused_deps_filter_included_target
