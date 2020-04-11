# shellcheck source=./test_runner.sh
dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
. "${dir}"/test_runner.sh
. "${dir}"/test_helper.sh
runner=$(get_test_runner "${1:-local}")

test_scala_import_library_passes_labels_of_direct_deps() {
  dependency_target='//test_expect_failure/scala_import:root_for_scala_import_passes_labels_of_direct_deps'
  test_target='test_expect_failure/scala_import:leaf_for_scala_import_passes_labels_of_direct_deps'

  test_scala_library_expect_failure_on_missing_direct_deps $dependency_target $test_target
}

test_plus_one_deps_only_works_for_java_info_targets() {
  #for example doesn't break scala proto which depends on proto_library
  bazel build --extra_toolchains="//test_expect_failure/plus_one_deps:plus_one_deps" //test/proto:test_proto
}

scala_pb_library_targets_do_not_have_host_deps() {
  set -e
  bazel build test/proto:test_binary_to_ensure_no_host_deps
  set +e
  find bazel-bin/test/proto/test_binary_to_ensure_no_host_deps.runfiles  -name '*.jar' -exec readlink {} \; | grep 'bazel-out/host'
  RET=$?
  set -e
  if [ "$RET" == "0" ]; then
    echo "Host deps exist in output of target:"
    echo "Possibly toolchains limitation?"
    find bazel-bin/test/proto/test_binary_to_ensure_no_host_deps.runfiles  -name '*.jar' -exec readlink {} \; | grep 'bazel-out/host'
    exit 1
  fi
}

test_scala_import_expect_failure_on_missing_direct_deps_warn_mode() {
  dependency_target1='//test_expect_failure/scala_import:cats'
  dependency_target2='//test_expect_failure/scala_import:guava'
  test_target='test_expect_failure/scala_import:scala_import_propagates_compile_deps'

  local expected_message1="buildozer 'add deps $dependency_target1' //$test_target"
  local expected_message2="buildozer 'add deps $dependency_target2' //$test_target"

  test_expect_failure_or_warning_on_missing_direct_deps_with_expected_message "${expected_message1}" ${test_target} "--strict_java_deps=warn" "ne" "${expected_message2}"
}

test_plus_one_ast_analyzer_strict_deps() {
  dependenecy_target='//test_expect_failure/missing_direct_deps/internal_deps:transitive_dependency'
  test_target='test_expect_failure/missing_direct_deps/internal_deps:transitive_dependency_user'

  expected_message_warn="warning: Target '$dependenecy_target' is used but isn't explicitly declared, please add it to the deps"
  expected_message_error="error: Target '$dependenecy_target' is used but isn't explicitly declared, please add it to the deps"

  test_expect_failure_or_warning_on_missing_direct_deps_with_expected_message "${expected_message_error}" ${test_target} "--extra_toolchains=//test/toolchains:ast_plus_one_deps_strict_deps_error" "eq"
  test_expect_failure_or_warning_on_missing_direct_deps_with_expected_message "${expected_message_error}" ${test_target} "--extra_toolchains=//scala:ast_plus_one_deps_strict_deps_unused_deps_error" "eq"
  test_expect_failure_or_warning_on_missing_direct_deps_with_expected_message "${expected_message_warn}" ${test_target} "--extra_toolchains=//test/toolchains:ast_plus_one_deps_strict_deps_warn" "ne"
}

$runner test_scala_import_library_passes_labels_of_direct_deps
$runner test_plus_one_deps_only_works_for_java_info_targets
$runner scala_pb_library_targets_do_not_have_host_deps
$runner test_scala_import_expect_failure_on_missing_direct_deps_warn_mode
$runner test_plus_one_ast_analyzer_strict_deps
