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

test_unused_dependency_checker_mode_warn() {
  # this is a hack to invalidate the cache, so that the target actually gets built and outputs warnings.
  bazel build \
    --strict_java_deps=warn \
    //test:UnusedDependencyCheckerWarn

  local output
  output=$(bazel build \
    --strict_java_deps=off \
    //test:UnusedDependencyCheckerWarn 2>&1
  )

  if [ $? -ne 0 ]; then
    echo "Target with unused dependency failed to build with status $?"
    echo "$output"
    exit 1
  fi

  local expected="warning: Target '//test:UnusedLib' is specified as a dependency to //test:UnusedDependencyCheckerWarn but isn't used, please remove it from the deps."

  echo "$output" | grep "$expected"
  if [ $? -ne 0 ]; then
    echo "Expected output:[$output] to contain [$expected]"
    exit 1
  fi
}

test_unused_dependency_fails_even_if_also_exists_in_plus_one_deps() {
  action_should_fail build --extra_toolchains="//test_expect_failure/plus_one_deps:plus_one_deps_with_unused_error" //test_expect_failure/plus_one_deps/with_unused_deps:a
}

test_plus_one_ast_analyzer_unused_deps() {
  action_should_fail build --extra_toolchains="//test/toolchains:ast_plus_one_deps_unused_deps_error" //test_expect_failure/plus_one_deps/with_unused_deps:a
  action_should_fail build --extra_toolchains="//test/toolchains:ast_plus_one_deps_strict_deps_unused_deps_error" //test_expect_failure/plus_one_deps/with_unused_deps:a
  action_should_fail build --extra_toolchains="//test/toolchains:ast_plus_one_deps_unused_deps_error" //test_expect_failure/plus_one_deps/with_unused_deps:a


  output=$(bazel build --extra_toolchains="//test/toolchains:ast_plus_one_deps_unused_deps_error" //test_expect_failure/plus_one_deps/with_unused_deps:a 2>&1
  )

  if [ $? -ne 0 ]; then
    echo "Target with unused dependency failed to build with status $?"
    echo "$output"
    exit 1
  fi

  local expected="warning: Target '//test_expect_failure/plus_one_deps/with_unused_deps:c' is specified as a dependency to //test_expect_failure/plus_one_deps/with_unused_deps:a but isn't used, please remove it from the deps."

  echo "$output" | grep "$expected"
  if [ $? -ne 0 ]; then
    echo "Expected output:[$output] to contain [$expected]"
    exit 1
  fi
}

test_plus_one_ast_analyzer_unused_deps_scala_test() {
  # We should not emit an unuse dep warning for scalatest library in a scala_test rule
  # even when the rule does not directly depend on scalatest. As scalatest is built into
  # the scala_test library.
  bazel build --extra_toolchains="//test/toolchains:ast_plus_one_deps_unused_deps_error" //test/scala_test:b
}

$runner test_unused_dependency_checker_mode_from_scala_toolchain
$runner test_unused_dependency_checker_mode_set_in_rule
$runner test_unused_dependency_checker_mode_override_toolchain
$runner test_unused_dependency_checker_mode_warn
$runner test_unused_dependency_fails_even_if_also_exists_in_plus_one_deps
$runner test_plus_one_ast_analyzer_unused_deps
$runner test_plus_one_ast_analyzer_unused_deps_scala_test
