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

test_scala_import_expect_failure_on_missing_direct_deps_warn_mode() {
  dependency_target1='//test_expect_failure/scala_import:cats'
  dependency_target2='//test_expect_failure/scala_import:guava'
  test_target='test_expect_failure/scala_import:scala_import_propagates_compile_deps'

  local expected_message1="buildozer 'add deps $dependency_target1' //$test_target"
  local expected_message2="buildozer 'add deps $dependency_target2' //$test_target"

  test_expect_failure_or_warning_on_missing_direct_deps_with_expected_message "${expected_message1}" ${test_target} "--extra_toolchains=//test/toolchains:high_level_transitive_deps_strict_deps_warn" "ne" "${expected_message2}"
}

test_plus_one_ast_analyzer_strict_deps() {
  dependenecy_target='//test_expect_failure/missing_direct_deps/internal_deps:transitive_dependency'
  test_target='test_expect_failure/missing_direct_deps/internal_deps:transitive_dependency_user'

  expected_message_warn="warning: Target '$dependenecy_target' is used but isn't explicitly declared, please add it to the deps"
  expected_message_error="error: Target '$dependenecy_target' is used but isn't explicitly declared, please add it to the deps"

  test_expect_failure_or_warning_on_missing_direct_deps_with_expected_message "${expected_message_error}" ${test_target} "--extra_toolchains=//test/toolchains:ast_plus_one_deps_strict_deps_error" "eq"
  test_expect_failure_or_warning_on_missing_direct_deps_with_expected_message "${expected_message_error}" ${test_target} "--extra_toolchains=//scala:minimal_direct_source_deps" "eq"
  test_expect_failure_or_warning_on_missing_direct_deps_with_expected_message "${expected_message_warn}" ${test_target} "--extra_toolchains=//test/toolchains:ast_plus_one_deps_strict_deps_warn" "ne"
}

test_stamped_target_label_loading() {
  local test_target="//test_expect_failure/missing_direct_deps/external_deps:java_lib_with_a_transitive_external_dep"
  local expected_message="buildozer 'add deps @io_bazel_rules_scala_guava//:io_bazel_rules_scala_guava' ${test_target}"

  test_expect_failure_or_warning_on_missing_direct_deps_with_expected_message \
    "${expected_message}" ${test_target} \
    "--extra_toolchains=//test/toolchains:ast_plus_one_deps_unused_deps_error" \
    "eq"
}

test_strict_deps_filter_excluded_target() {
  bazel build //test_expect_failure/missing_direct_deps/filtering:a \
    --extra_toolchains=//test_expect_failure/missing_direct_deps/filtering:plus_one_strict_deps_filter
}

test_strict_deps_filter_included_target() {
  local test_target="//test_expect_failure/missing_direct_deps/filtering:b"
  local expected_message="buildozer 'add deps @com_google_guava_guava_21_0//:com_google_guava_guava_21_0' ${test_target}"

  test_expect_failure_or_warning_on_missing_direct_deps_with_expected_message \
    "${expected_message}" ${test_target} \
    "--extra_toolchains=//test_expect_failure/missing_direct_deps/filtering:plus_one_strict_deps_filter" \
    "eq"
}

test_demonstrate_INCORRECT_scala_proto_library_stamp() {
  local test_target="//test_expect_failure/missing_direct_deps/scala_proto_deps:uses_transitive_scala_proto"
  local incorrectly_stamped_expected_message="buildozer 'add deps //test_expect_failure/missing_direct_deps/scala_proto_deps:some_proto' ${test_target}"

  # When stamping is fixed, expected stamp is:
  # local correctly_stamped_expected_message="buildozer 'add deps //test_expect_failure/missing_direct_deps/scala_proto_deps:some_scala_proto' ${test_target}"

  test_expect_failure_or_warning_on_missing_direct_deps_with_expected_message \
    "${incorrectly_stamped_expected_message}" ${test_target} \
    "--extra_toolchains=//test/toolchains:ast_plus_one_deps_strict_deps_error" \
    "eq"
}

test_scala_proto_library_stamp_by_convention() {
  local test_target="//test_expect_failure/missing_direct_deps/scala_proto_deps:uses_transitive_scala_proto"
  local expected_message="buildozer 'add deps //test_expect_failure/missing_direct_deps/scala_proto_deps:some_scala_proto' ${test_target}"

  test_expect_failure_or_warning_on_missing_direct_deps_with_expected_message \
    "${expected_message}" ${test_target} \
    "--extra_toolchains=//test/toolchains:ast_plus_one_deps_strict_deps_error,//test_expect_failure/missing_direct_deps/scala_proto_deps:stamp_by_convention_toolchain" \
    "eq"
}

$runner test_scala_import_library_passes_labels_of_direct_deps
$runner test_plus_one_deps_only_works_for_java_info_targets
$runner test_scala_import_expect_failure_on_missing_direct_deps_warn_mode
$runner test_plus_one_ast_analyzer_strict_deps
$runner test_stamped_target_label_loading
$runner test_strict_deps_filter_excluded_target
$runner test_strict_deps_filter_included_target
$runner test_demonstrate_INCORRECT_scala_proto_library_stamp
$runner test_scala_proto_library_stamp_by_convention
