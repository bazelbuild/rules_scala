# shellcheck source=./test_runner.sh
dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
. "${dir}"/test_runner.sh
. "${dir}"/test_helper.sh
runner=$(get_test_runner "${1:-local}")

revert_internal_change() {
  sed -i.bak "s/println(\"altered\")/println(\"orig\")/" $no_recompilation_path/C.scala
  rm $no_recompilation_path/C.scala.bak
}

revert_change() {
  mv $1/$2.bak $1/$2
}

test_scala_library_expect_no_recompilation_on_internal_change() {
  changed_file=$1
  changed_content=$2
  dependency=$3
  dependency_description=$4
  set +e
  no_recompilation_path="test/src/main/scala/scalarules/test/ijar"
  build_command="bazel build //$no_recompilation_path/... --subcommands"

  echo "running initial build"
  $build_command
  echo "changing internal behaviour of $changed_file"
  sed -i.bak $changed_content ./$no_recompilation_path/$changed_file

  echo "running second build"
  output=$(${build_command} 2>&1)

  not_expected_recompiled_action="$no_recompilation_path$dependency"

  echo ${output} | grep "$not_expected_recompiled_action"
  if [ $? -eq 0 ]; then
    echo "bazel build was executed after change of internal behaviour of 'dependency' target. compilation of $dependency_description should not have been triggered."
    revert_change $no_recompilation_path $changed_file
    exit 1
  fi

  revert_change $no_recompilation_path $changed_file
  set -e
}

test_scala_library_expect_no_recompilation_of_target_on_internal_change_of_dependency() {
  test_scala_library_expect_no_recompilation_on_internal_change $1 $2 ":user" "'user'"
}

test_scala_library_suite() {
  action_should_fail build test_expect_failure/scala_library_suite:library_suite_dep_on_children
}

test_scala_library_expect_failure_on_missing_direct_internal_deps() {
  dependenecy_target='//test_expect_failure/missing_direct_deps/internal_deps:transitive_dependency'
  test_target='test_expect_failure/missing_direct_deps/internal_deps:transitive_dependency_user'

  test_scala_library_expect_failure_on_missing_direct_deps $dependenecy_target $test_target
}

test_scala_library_expect_failure_on_missing_direct_external_deps_jar() {
  dependenecy_target='@com_google_guava_guava_21_0//:com_google_guava_guava_21_0'
  test_target='test_expect_failure/missing_direct_deps/external_deps:transitive_external_dependency_user'

  test_scala_library_expect_failure_on_missing_direct_deps $dependenecy_target $test_target
}

test_scala_library_expect_failure_on_missing_direct_external_deps_file_group() {
  dependenecy_target='@com_google_guava_guava_21_0_with_file//:com_google_guava_guava_21_0_with_file'
  test_target='test_expect_failure/missing_direct_deps/external_deps:transitive_external_dependency_user_file_group'

  test_scala_library_expect_failure_on_missing_direct_deps $dependenecy_target $test_target
}

test_scala_library_expect_failure_on_missing_direct_deps_strict_is_disabled_by_default() {
  expected_message="not found: value C"
  test_target='test_expect_failure/missing_direct_deps/internal_deps:transitive_dependency_user'

  test_expect_failure_or_warning_on_missing_direct_deps_with_expected_message "$expected_message" $test_target ""
}

test_scala_library_expect_failure_on_missing_direct_deps_warn_mode() {
  dependenecy_target='//test_expect_failure/missing_direct_deps/internal_deps:transitive_dependency'
  test_target='test_expect_failure/missing_direct_deps/internal_deps:transitive_dependency_user'

  expected_message="warning: Target '$dependenecy_target' is used but isn't explicitly declared, please add it to the deps"

  test_expect_failure_or_warning_on_missing_direct_deps_with_expected_message "${expected_message}" ${test_target} "--extra_toolchains=//test/toolchains:ast_transitive_deps_strict_deps_warn" "ne"
}

test_scala_library_expect_failure_on_missing_direct_deps_warn_mode_java() {
  dependency_target='//test_expect_failure/missing_direct_deps/internal_deps:transitive_dependency'
  test_target='//test_expect_failure/missing_direct_deps/internal_deps:transitive_dependency_java_user'

  local expected_message="$dependency_target.*$test_target"

  test_expect_failure_or_warning_on_missing_direct_deps_with_expected_message "${expected_message}" ${test_target} "--strict_java_deps=warn" "ne"
}

test_scala_library_expect_failure_on_missing_direct_deps_off_mode() {
  expected_message="test_expect_failure/missing_direct_deps/internal_deps/A.scala:[0-9+]: error: not found: value C"
  test_target='test_expect_failure/missing_direct_deps/internal_deps:transitive_dependency_user'

  test_expect_failure_or_warning_on_missing_direct_deps_with_expected_message "${expected_message}" ${test_target} "--extra_toolchains=//test/toolchains:high_level_direct_deps"
}

test_scala_library_expect_no_recompilation_on_internal_change_of_transitive_dependency() {
  set +e
  no_recompilation_path="test/src/main/scala/scalarules/test/strict_deps/no_recompilation"
  build_command="bazel build //$no_recompilation_path/... --subcommands --extra_toolchains=//test/toolchains:ast_transitive_deps_strict_deps_error"

  echo "running initial build"
  $build_command
  echo "changing internal behaviour of C.scala"
  sed -i.bak "s/println(\"orig\")/println(\"altered\")/" ./$no_recompilation_path/C.scala

  echo "running second build"
  output=$(${build_command} 2>&1)

  not_expected_recompiled_target="//$no_recompilation_path:transitive_dependency_user"

  echo ${output} | grep "$not_expected_recompiled_target"
  if [ $? -eq 0 ]; then
    echo "bazel build was executed after change of internal behaviour of 'transitive_dependency' target. compilation of 'transitive_dependency_user' should not have been triggered."
    revert_internal_change
    exit 1
  fi

  revert_internal_change
  set -e
}

test_scala_library_expect_no_recompilation_on_internal_change_of_scala_dependency() {
  test_scala_library_expect_no_recompilation_of_target_on_internal_change_of_dependency "B.scala" "s/println(\"orig\")/println(\"altered\")/"
}

test_scala_library_expect_no_recompilation_on_internal_change_of_java_dependency() {
  test_scala_library_expect_no_recompilation_of_target_on_internal_change_of_dependency "C.java" "s/System.out.println(\"orig\")/System.out.println(\"altered\")/"
}

test_scala_library_expect_no_java_recompilation_on_internal_change_of_scala_sibling() {
  test_scala_library_expect_no_recompilation_on_internal_change "B.scala" "s/println(\"orig_sibling\")/println(\"altered_sibling\")/" "/dependency_java" "java sibling"
}

test_scala_library_expect_failure_on_missing_direct_java() {
  dependency_target='//test_expect_failure/missing_direct_deps/internal_deps:transitive_dependency'
  test_target='//test_expect_failure/missing_direct_deps/internal_deps:transitive_dependency_java_user'

  expected_message="$dependency_target.*$test_target"

  test_expect_failure_or_warning_on_missing_direct_deps_with_expected_message "${expected_message}" $test_target "--strict_java_deps=error"
}

test_scala_library_expect_failure_on_java_in_src_jar_when_disabled() {
  test_target='//test_expect_failure/java_in_src_jar_when_disabled:java_source_jar'

  expected_message=".*Found java files in source jars but expect Java output is set to false"

  test_expect_failure_with_message "${expected_message}" $test_target
}

test_scala_library_expect_better_failure_message_on_missing_transitive_dependency_labels_from_other_jvm_rules() {
  transitive_target='.*transitive_dependency-ijar.jar'
  direct_target='//test_expect_failure/missing_direct_deps/internal_deps:direct_java_provider_dependency'
  test_target='//test_expect_failure/missing_direct_deps/internal_deps:dependent_on_some_java_provider'

  expected_message="Unknown label of file $transitive_target which came from $direct_target"

  test_expect_failure_or_warning_on_missing_direct_deps_with_expected_message "${expected_message}" $test_target "--extra_toolchains=//test/toolchains:ast_transitive_deps_strict_deps_error"
}

$runner test_scala_library_suite
$runner test_scala_library_expect_failure_on_missing_direct_internal_deps
$runner test_scala_library_expect_failure_on_missing_direct_external_deps_jar
$runner test_scala_library_expect_failure_on_missing_direct_external_deps_file_group
$runner test_scala_library_expect_failure_on_missing_direct_deps_strict_is_disabled_by_default
$runner test_scala_library_expect_failure_on_missing_direct_deps_warn_mode
$runner test_scala_library_expect_failure_on_missing_direct_deps_warn_mode_java
$runner test_scala_library_expect_failure_on_missing_direct_deps_off_mode
$runner test_scala_library_expect_no_recompilation_on_internal_change_of_transitive_dependency
$runner test_scala_library_expect_no_recompilation_on_internal_change_of_scala_dependency
$runner test_scala_library_expect_no_recompilation_on_internal_change_of_java_dependency
$runner test_scala_library_expect_no_java_recompilation_on_internal_change_of_scala_sibling
$runner test_scala_library_expect_failure_on_missing_direct_java
$runner test_scala_library_expect_failure_on_java_in_src_jar_when_disabled
$runner test_scala_library_expect_better_failure_message_on_missing_transitive_dependency_labels_from_other_jvm_rules
