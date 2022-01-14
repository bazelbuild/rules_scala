# shellcheck source=./test_runner.sh
dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
. "${dir}"/test_runner.sh
. "${dir}"/test_helper.sh
runner=$(get_test_runner "${1:-local}")

scala_specs2_junit_test_test_filter_everything(){
  local output=$(bazel test \
    --nocache_test_results \
    --test_output=streamed \
    '--test_filter=.*' \
    test:Specs2Tests)
  local expected=(
    "[info] JunitSpec2RegexTest"
    "[info] JunitSpecs2AnotherTest"
    "[info] JunitSpecs2Test"
    "[info] JunitSpecs2ManyFragmentsTest")
  local unexpected=(
      "[info] UnrelatedTest")
  for method in "${expected[@]}"; do
    if ! grep "$method" <<<$output; then
      echo "output:"
      echo "$output"
      echo "Expected $method in output, but was not found."
      exit 1
    fi
  done
  for method in "${unexpected[@]}"; do
    if grep "$method" <<<$output; then
      echo "output:"
      echo "$output"
      echo "Not expecting $method in output, but was found."
      exit 1
    fi
  done
}

scala_specs2_junit_test_test_filter_one_test(){
  local output=$(bazel test \
    --nocache_test_results \
    --test_output=streamed \
    '--test_filter=scalarules.test.junit.specs2.JunitSpecs2Test#specs2 tests::run smoothly in bazel$' \
    test:Specs2Tests)
  local expected="+ run smoothly in bazel"
  local unexpected="+ not run smoothly in bazel"
  if ! grep "$expected" <<<$output; then
    echo "output:"
    echo "$output"
    echo "Expected $expected in output, but was not found."
    exit 1
  fi
  if grep "$unexpected" <<<$output; then
    echo "output:"
    echo "$output"
    echo "Not expecting $unexpected in output, but was found."
    exit 1
  fi
}

scala_specs2_junit_test_test_filter_whole_spec(){
  local output=$(bazel test \
    --nocache_test_results \
    --test_output=streamed \
    '--test_filter=scalarules.test.junit.specs2.JunitSpecs2Test#' \
    test:Specs2Tests)
  local expected=(
      "+ run smoothly in bazel"
      "+ not run smoothly in bazel")
  local unexpected=(
      "+ run from another test")
  for method in "${expected[@]}"; do
    if ! grep "$method" <<<$output; then
      echo "output:"
      echo "$output"
      echo "Expected $method in output, but was not found."
      exit 1
    fi
  done
  for method in "${unexpected[@]}"; do
    if grep "$method" <<<$output; then
      echo "output:"
      echo "$output"
      echo "Not expecting $method in output, but was found."
      exit 1
    fi
  done
}

scala_specs2_junit_test_test_filter_exact_match(){
  local output=$(bazel test \
    --nocache_test_results \
    --test_output=streamed \
    '--test_filter=scalarules.test.junit.specs2.JunitSpecs2AnotherTest#other specs2 tests::run from another test$' \
    test:Specs2Tests)
  local expected="+ run from another test"
  local unexpected="+ run from another test 2"
  if ! grep "$expected" <<<$output; then
    echo "output:"
    echo "$output"
    echo "Expected $expected in output, but was not found."
    exit 1
  fi
  if grep "$unexpected" <<<$output; then
    echo "output:"
    echo "$output"
    echo "Not expecting $unexpected in output, but was found."
    exit 1
  fi
}

scala_specs2_junit_test_test_filter_exact_match_unsafe_characters(){
  local output=$(bazel test \
    --nocache_test_results \
    --test_output=streamed \
    '--test_filter=scalarules.test.junit.specs2.JunitSpec2RegexTest#\Qtests with unsafe characters::2 + 2 != 5\E$' \
    test:Specs2Tests)
  local expected="+ 2 + 2 != 5"
  local unexpected="+ work escaped (with regex)"
  if ! grep "$expected" <<<$output; then
    echo "output:"
    echo "$output"
    echo "Expected $expected in output, but was not found."
    exit 1
  fi
  if grep "$unexpected" <<<$output; then
    echo "output:"
    echo "$output"
    echo "Not expecting $unexpected in output, but was found."
    exit 1
  fi
}

scala_specs2_junit_test_test_filter_exact_match_escaped_and_sanitized(){
  local output=$(bazel test \
    --nocache_test_results \
    --test_output=streamed \
    '--test_filter=scalarules.test.junit.specs2.JunitSpec2RegexTest#\Qtests with unsafe characters::work escaped [with regex]\E$' \
    test:Specs2Tests)
  local expected="+ work escaped (with regex)"
  local unexpected="+ 2 + 2 != 5"
  if ! grep "$expected" <<<$output; then
    echo "output:"
    echo "$output"
    echo "Expected $expected in output, but was not found."
    exit 1
  fi
  if grep "$unexpected" <<<$output; then
    echo "output:"
    echo "$output"
    echo "Not expecting $unexpected in output, but was found."
    exit 1
  fi
}

scala_specs2_junit_test_test_filter_match_multiple_methods(){
  local output=$(bazel test \
    --nocache_test_results \
    --test_output=streamed \
    '--test_filter=scalarules.test.junit.specs2.JunitSpecs2AnotherTest#other specs2 tests::(\Qrun from another test\E|\Qrun from another test 2\E)$' \
    test:Specs2Tests)
  local expected=(
      "+ run from another test"
      "+ run from another test 2")
  local unexpected=(
      "+ not run")
  for method in "${expected[@]}"; do
    if ! grep "$method" <<<$output; then
      echo "output:"
      echo "$output"
      echo "Expected $method in output, but was not found."
      exit 1
    fi
  done
  for method in "${unexpected[@]}"; do
    if grep "$method" <<<$output; then
      echo "output:"
      echo "$output"
      echo "Not expecting $method in output, but was found."
      exit 1
    fi
  done
}

scala_specs2_exception_in_initializer_without_filter(){
  expected_message="org.specs2.control.UserException: cannot create an instance for class scalarules.test.junit.specs2.FailingTest"
  test_command="test_expect_failure/scala_junit_test:specs2_failing_test"

  test_expect_failure_with_message "$expected_message" $test_filter $test_command
}

scala_specs2_exception_in_initializer_terminates_without_timeout(){
  local output=$(bazel test \
    --test_output=streamed \
    --test_timeout=10 \
    '--test_filter=scalarules.test.junit.specs2.FailingTest#' \
    test_expect_failure/scala_junit_test:specs2_failing_test)
  local expected=(
      "org.specs2.control.UserException: cannot create an instance for class scalarules.test.junit.specs2.FailingTest")
  local unexpected=(
      "TIMEOUT")
  for method in "${expected[@]}"; do
    if ! grep "$method" <<<$output; then
      echo "output:"
      echo "$output"
      echo "Expected $method in output, but was not found."
      exit 1
    fi
  done
  for method in "${unexpected[@]}"; do
    if grep "$method" <<<$output; then
      echo "output:"
      echo "$output"
      echo "Not expecting $method in output, but was found."
      exit 1
    fi
  done
}

scala_specs2_all_tests_show_in_the_xml(){
  bazel test \
    --nocache_test_results \
    --test_output=streamed \
    '--test_filter=scalarules.test.junit.specs2.JunitSpecs2Test#' \
    test:Specs2Tests
  matches=$(grep -c -e "testcase name='specs2 tests::run smoothly in bazel'" -e "testcase name='specs2 tests should::not run smoothly in bazel'" ./bazel-testlogs/test/Specs2Tests/test.xml)
  if [ $matches -eq 2 ]; then
    return 0
  else
    echo "Expecting two results, found a different number ($matches). Please check 'bazel-testlogs/test/Specs2Tests/test.xml'"
    return 1
  fi
  test -e
}

scala_specs2_only_filtered_test_shows_in_the_xml(){
  bazel test \
    --nocache_test_results \
    --test_output=streamed \
    '--test_filter=scalarules.test.junit.specs2.JunitSpecs2Test#specs2 tests::run smoothly in bazel$' \
    test:Specs2Tests
  matches=$(grep -c -e "testcase name='specs2 tests::run smoothly in bazel'" -e "testcase name='specs2 tests::not run smoothly in bazel'" ./bazel-testlogs/test/Specs2Tests/test.xml)
  if [ $matches -eq 1 ]; then
    return 0
  else
    echo "Expecting only one result, found more than one. Please check 'bazel-testlogs/test/Specs2Tests/test.xml'"
    return 1
  fi
  test -e
}

scala_specs2_only_failed_test_shows_in_the_xml(){
  set +e
  bazel test \
  --nocache_test_results \
  --test_output=streamed \
  '--test_filter=scalarules.test.junit.specs2.SuiteWithOneFailingTest#specs2 tests should::fail$' \
  test_expect_failure/scala_junit_test:specs2_failing_test
  echo "got results"
  matches=$(grep -c -e "testcase name='specs2 tests should::fail'" -e "testcase name='specs2 tests should::succeed'" ./bazel-testlogs/test_expect_failure/scala_junit_test/specs2_failing_test/test.xml)
  if [ $matches -eq 1 ]; then
    return 0
  else
    echo "Expecting only one result, found more than one. Please check './bazel-testlogs/test_expect_failure/scala_junit_test/specs2_failing_test/test.xml'"
  return 1
  fi
}

$runner scala_specs2_junit_test_test_filter_everything
$runner scala_specs2_junit_test_test_filter_one_test
$runner scala_specs2_junit_test_test_filter_whole_spec
$runner scala_specs2_junit_test_test_filter_exact_match
$runner scala_specs2_junit_test_test_filter_exact_match_unsafe_characters
$runner scala_specs2_junit_test_test_filter_exact_match_escaped_and_sanitized
$runner scala_specs2_junit_test_test_filter_match_multiple_methods
$runner scala_specs2_exception_in_initializer_without_filter
$runner scala_specs2_exception_in_initializer_terminates_without_timeout
$runner scala_specs2_all_tests_show_in_the_xml
$runner scala_specs2_only_filtered_test_shows_in_the_xml
$runner scala_specs2_only_failed_test_shows_in_the_xml
