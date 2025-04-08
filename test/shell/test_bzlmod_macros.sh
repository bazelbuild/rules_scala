#!/usr/bin/env bash
#
# Tests for //scala/private:macros/bzlmod.bzl

set -e

dir="$( cd "${BASH_SOURCE[0]%/*}" && echo "${PWD%/test/shell}" )"
test_source="${dir}/test/shell/${BASH_SOURCE[0]#*test/shell/}"
# shellcheck source=./test_runner.sh
. "${dir}"/test/shell/test_runner.sh
. "${dir}"/test/shell/test_helper.sh
export USE_BAZEL_VERSION=${USE_BAZEL_VERSION:-$(cat $dir/.bazelversion)}

# Setup and teardown

setup_suite() {
  if [[ "$(bazel --version)" =~ ^bazel\ 6\. ]]; then
    src_file="${test_source#$dir/}"
    echo -e "${YELLOW}${src_file} not compatible with Bazel 6, skipping...${NC}"
    test_source='/dev/null'
    return
  fi

  original_dir="$PWD"
  setup_test_tmpdir_for_file "$original_dir" "$test_source"
  test_tmpdir="$PWD"

  rules_scala_dir="$(relative_path_to_parent "$original_dir" "$test_tmpdir")"
  test_srcs_dir="${dir}/scala/private/macros/test"
  test_tmpdir_base="${test_tmpdir##*/}"
  test_module_bazel_regex="[^ ]+${test_tmpdir_base}/MODULE.bazel"

  local bk_bazel_rc="${dir}/tools/bazel.rc"

  if [[ -f "$bk_bazel_rc" ]]; then
    # test_rules_scala_jdk21 from .bazelci/presubmit.yml needs this.
    mkdir tools
    cp "${bk_bazel_rc}" tools/
  fi
}

teardown_suite() {
    teardown_test_tmpdir "$original_dir" "$test_tmpdir"
}

setup_test_module() {
  set -e
  cp "${dir}"/.bazel{rc,version} "${test_srcs_dir}"/bzlmod_test_ext.bzl .
  cp "${test_srcs_dir}/BUILD.bzlmod_test" 'BUILD'

  sed -e "s%\${rules_scala_dir}%${rules_scala_dir}%" \
    "${test_srcs_dir}/MODULE.bzlmod_test" > 'MODULE.bazel'

  printf '%s\n' "$@" >>'MODULE.bazel'
}

# Test utilities

bazel_run_args=('run' '--enable_bzlmod')
print_single_test_tag_values_target='//:print-single-test-tag-values'
print_repeated_test_tag_values_target='//:print-repeated-test-tag-values'

print_single_test_tag_values() {
  bazel "${bazel_run_args[@]}" "$print_single_test_tag_values_target" 2>&1
}

print_single_test_tag_values_should_fail_with_message() {
  local expected=(
    "expected one regular tag instance and/or one dev_dependency instance,"
    "${1}: 'single_test_tag' tag at ${test_module_bazel_regex}:"
  )

  action_should_fail_with_message "${expected[*]}" \
    "${bazel_run_args[@]}" "$print_single_test_tag_values_target"
}

print_repeated_test_tag_values() {
  bazel "${bazel_run_args[@]}" "$print_repeated_test_tag_values_target" 2>&1
}

# Test cases

test_bzlmod_single_tag_values_returns_defaults_when_no_root_tag() {
  setup_test_module

  assert_matches 'foo bar baz$' "$(print_single_test_tag_values)"
}

test_bzlmod_creates_fake_root_module_tags_when_unused_by_root_module() {
  # This setup is a bit more involved because this is the only test that sets
  # up the test module as a non-root module.
  local test_module_dir="../${test_tmpdir_base}_test_module"

  mkdir "$test_module_dir"
  cd "$test_module_dir"
  setup_test_module
  cd "$test_tmpdir"

  sed -e "s%\${rules_scala_dir}%${rules_scala_dir}%" \
    -e "s%\${test_module_dir}%${test_module_dir}%" \
    "${test_srcs_dir}/MODULE.bzlmod_test_root_module" > 'MODULE.bazel'

  local target='@test_module//:print-single-test-tag-values'
  local tag_values="$(bazel run --enable_bzlmod "$target")"

  assert_matches 'foo bar baz$' "$tag_values"
  rm -rf "$test_module_dir"
}

test_bzlmod_single_tag_values_returns_regular_root_tag_values() {
  setup_test_module \
    'test_ext.single_test_tag(first = "quux", third = "plugh")'

  assert_matches 'quux bar plugh$' "$(print_single_test_tag_values)"
}

test_bzlmod_single_tag_values_returns_dev_root_tag_values() {
  setup_test_module \
    'dev_test_ext.single_test_tag(first = "quux", third = "plugh")'

  assert_matches 'quux bar plugh$' "$(print_single_test_tag_values)"
}

test_bzlmod_single_tag_values_combines_regular_and_dev_dep_tags() {
  setup_test_module \
    'test_ext.single_test_tag(first = "quux", third = "plugh")' \
    'dev_test_ext.single_test_tag(second = "xyzzy", third = "frobozz")'

  # Dev values matching the default won't overwrite regular tag values.
  assert_matches 'quux xyzzy frobozz$' "$(print_single_test_tag_values)"
}

test_bzlmod_single_tag_values_fails_if_more_than_two_tags() {
  setup_test_module \
    'test_ext.single_test_tag()' \
    'dev_test_ext.single_test_tag()' \
    'dev_test_ext.single_test_tag(second = "not", third = "happening")'

  print_single_test_tag_values_should_fail_with_message "got 3"
}

test_bzlmod_single_tag_values_fails_if_dev_tag_before_regular() {
  setup_test_module \
    'dev_test_ext.single_test_tag()' \
    'test_ext.single_test_tag(first = "should be, but isn''t")'

  print_single_test_tag_values_should_fail_with_message \
    "got the dev_dependency instance before the regular instance"
}

test_bzlmod_single_tag_values_fails_if_two_regular_tags() {
  setup_test_module \
    'test_ext.single_test_tag(first = "of two")' \
    'test_ext.single_test_tag(second = "of two")'

  print_single_test_tag_values_should_fail_with_message \
    "got two regular instances"
}

test_bzlmod_single_tag_values_fails_if_two_dev_tags() {
  setup_test_module \
    'dev_test_ext.single_test_tag(first = "of two")' \
    'dev_test_ext.single_test_tag(second = "of two")'

  print_single_test_tag_values_should_fail_with_message \
    "got two dev_dependency instances"
}

test_bzlmod_repeated_tag_values_for_zero_instances() {
  setup_test_module

  assert_matches '\{\}$' "$(print_repeated_test_tag_values)"
}

test_bzlmod_repeated_tag_values_for_one_instance() {
  setup_test_module \
    'test_ext.repeated_test_tag(unique_key = "foo", required = "bar")'

  assert_matches '\{"foo": \{"required": "bar", "optional": ""\}\}$' \
    "$(print_repeated_test_tag_values)"
}

test_bzlmod_repeated_tag_values_for_multiple_instances() {
  setup_test_module \
    'test_ext.repeated_test_tag(unique_key = "foo", required = "bar")' \
    'test_ext.repeated_test_tag(' \
    '    unique_key = "baz",' \
    '    required = "quux",' \
    '    optional = "xyzzy",' \
    ')' \
    'dev_test_ext.repeated_test_tag(' \
    '    unique_key = "plugh",' \
    '    required = "frobozz",' \
    ')'

  local expected=(
    '\{"foo": \{"required": "bar", "optional": ""\},'
    '"baz": \{"required": "quux", "optional": "xyzzy"\},'
    '"plugh": \{"required": "frobozz", "optional": ""\}\}$'
  )

  assert_matches "${expected[*]}" "$(print_repeated_test_tag_values)"
}

test_bzlmod_repeated_tag_values_fails_on_duplicate_key() {
  setup_test_module \
    'test_ext.repeated_test_tag(unique_key = "foo", required = "bar")' \
    'dev_test_ext.repeated_test_tag(unique_key = "foo", required = "baz")'

  local expected=(
    "multiple tags with same unique_key:"
    "'repeated_test_tag' tag at ${test_module_bazel_regex}:"
  )

  action_should_fail_with_message "${expected[*]}" \
    "${bazel_run_args[@]}" "$print_repeated_test_tag_values_target"
}

setup_suite
run_tests "$test_source" "$(get_test_runner "${1:-local}")"
teardown_suite
