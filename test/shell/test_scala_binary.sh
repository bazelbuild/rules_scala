# shellcheck source=./test_runner.sh
dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
. "${dir}"/test_runner.sh
. "${dir}"/test_helper.sh
runner=$(get_test_runner "${1:-local}")

test_scala_binary_expect_failure_on_missing_direct_deps() {
  dependency_target='//test_expect_failure/missing_direct_deps/internal_deps:transitive_dependency'
  test_target='test_expect_failure/missing_direct_deps/internal_deps:user_binary'

  test_scala_library_expect_failure_on_missing_direct_deps ${dependency_target} ${test_target}
}

test_scala_binary_expect_failure_on_missing_direct_deps_located_in_dependency_which_is_scala_binary() {
  dependency_target='//test_expect_failure/missing_direct_deps/internal_deps:transitive_dependency'
  test_target='test_expect_failure/missing_direct_deps/internal_deps:binary_user_of_binary'

  test_scala_library_expect_failure_on_missing_direct_deps ${dependency_target} ${test_target}
}

$runner test_scala_binary_expect_failure_on_missing_direct_deps
$runner test_scala_binary_expect_failure_on_missing_direct_deps_located_in_dependency_which_is_scala_binary
