#!/bin/bash

set -e

test_disappearing_class() {
  git checkout test_expect_failure/disappearing_class/ClassProvider.scala
  bazel build test_expect_failure/disappearing_class:uses_class
  echo -e "package scala.test\n\nobject BackgroundNoise{}" > test_expect_failure/disappearing_class/ClassProvider.scala
  set +e
  bazel build test_expect_failure/disappearing_class:uses_class
  RET=$?
  git checkout test_expect_failure/disappearing_class/ClassProvider.scala
  if [ $RET -eq 0 ]; then
    echo "Class caching at play. This should fail"
    exit 1
  fi
  set -e
}
md5_util() {
if [[ "$OSTYPE" == "darwin"* ]]; then
   _md5_util="md5"
else
   _md5_util="md5sum"
fi
echo "$_md5_util"
}

test_build_is_identical() {
  bazel build test/...
  $(md5_util) bazel-bin/test/*.jar > hash1
  bazel clean
  bazel build test/...
  $(md5_util) bazel-bin/test/*.jar > hash2
  diff hash1 hash2
}

test_transitive_deps() {
  set +e

  bazel build test_expect_failure/transitive/scala_to_scala:d
  if [ $? -eq 0 ]; then
    echo "'bazel build test_expect_failure/transitive/scala_to_scala:d' should have failed."
    exit 1
  fi

  bazel build test_expect_failure/transitive/java_to_scala:d
  if [ $? -eq 0 ]; then
    echo "'bazel build test_expect_failure/transitive/java_to_scala:d' should have failed."
    exit 1
  fi

  bazel build test_expect_failure/transitive/scala_to_java:d
  if [ $? -eq 0 ]; then
    echo "'bazel build test_transitive_deps/scala_to_java:d' should have failed."
    exit 1
  fi

  set -e
  exit 0
}

test_scala_library_suite() {
  action_should_fail build test_expect_failure/scala_library_suite:library_suite_dep_on_children
}

test_scala_library_expect_failure_on_missing_direct_deps() {
  expected_message="Target '//test_expect_failure/missing_direct_deps:direct_dependency' is used but isn't explicitly declared, please add it to the deps"
  command='bazel build test_expect_failure/missing_direct_deps:transitive_dependency_user'
  output=$($command 2>&1)
  if [  $? -eq 0 ]; then
    echo "$output"
    echo "'bazel build of scala_library with missing direct deps should have failed."
    exit 1
  fi
  echo "$output"
  echo $output | grep "$expected_message"
  if [ $? -ne 0 ]; then
    echo "'bazel build test_expect_failure/missing_direct_deps:transitive_dependency_user' should have logged \"$expected_message\"."
    exit 1
  fi
  exit 0
}

test_scala_junit_test_can_fail() {
  action_should_fail test test_expect_failure/scala_junit_test:failing_test
}

test_repl() {
  echo "import scala.test._; HelloLib.printMessage(\"foo\")" | bazel-bin/test/HelloLibRepl | grep "foo java" &&
  echo "import scala.test._; TestUtil.foo" | bazel-bin/test/HelloLibTestRepl | grep "bar" &&
  echo "import scala.test._; ScalaLibBinary.main(Array())" | bazel-bin/test/ScalaLibBinaryRepl | grep "A hui hou" &&
  echo "import scala.test._; ResourcesStripScalaBinary.main(Array())" | bazel-bin/test/ResourcesStripScalaBinaryRepl | grep "More Hello"
  echo "import scala.test._; A.main(Array())" | bazel-bin/test/ReplWithSources | grep "4 8 15"
}

test_benchmark_jmh() {
  RES=$(bazel run -- test/jmh:test_benchmark -i1 -f1 -wi 1)
  RESPONSE_CODE=$?
  if [[ $RES != *Result*Benchmark* ]]; then
    echo "Benchmark did not produce expected output:\n$RES"
    exit 1
  fi
  exit $RESPONSE_CODE
}

NC='\033[0m'
GREEN='\033[0;32m'
RED='\033[0;31m'
TIMOUT=60

run_test_ci() {
  # spawns the test to new process
  local TEST_ARG=$@
  local log_file=output_$$.log
  echo "running test $TEST_ARG"
  $TEST_ARG &>$log_file &
  local test_pid=$!
  SECONDS=0
  test_pulse_printer $! $TIMOUT $TEST_ARG &
  local pulse_printer_pid=$!
  local result

  {
    wait $test_pid 2>/dev/null
    result=$?
    kill $pulse_printer_pid && wait $pulse_printer_pid 2>/dev/null || true
  } || return 1
  
  DURATION=$SECONDS
  if [ $result -eq 0 ]; then
    echo -e "\n${GREEN}Test \"$TEST_ARG\" successful ($DURATION sec) $NC"
  else
    echo -e "\nLog:\n"
    cat $log_file
    echo -e "\n${RED}Test \"$TEST_ARG\" failed $NC ($DURATION sec) $NC"
  fi
  return $result
}

test_pulse_printer() {
  # makes sure something is printed to stdout while test is running
  local test_pid=$1
  shift
  local timeout=$1 # in minutes
  shift
  local count=0

  # clear the line
  echo -e "\n"

  while [ $count -lt $timeout ]; do
    count=$(($count + 1))
    echo -ne "Still running: \"$@\"\r"
    sleep 60
  done

  echo -e "\n${RED}Timeout (${timeout} minutes) reached. Terminating \"$@\"${NC}\n"
  kill -9 $test_pid
}

run_test_local() {
  # runs the tests locally
  set +e
  SECONDS=0
  TEST_ARG=$@
  echo "running test $TEST_ARG"
  RES=$($TEST_ARG 2>&1)
  RESPONSE_CODE=$?
  DURATION=$SECONDS
  if [ $RESPONSE_CODE -eq 0 ]; then
    echo -e "${GREEN} Test \"$TEST_ARG\" successful ($DURATION sec) $NC"
  else
    echo -e "\nLog:\n"
    echo "$RES"
    echo -e "${RED} Test \"$TEST_ARG\" failed $NC ($DURATION sec) $NC"
    exit $RESPONSE_CODE
  fi
}

action_should_fail() {
  # runs the tests locally
  set +e
  TEST_ARG=$@
  $(bazel $TEST_ARG)
  RESPONSE_CODE=$?
  if [ $RESPONSE_CODE -eq 0 ]; then
    echo -e "${RED} \"bazel $TEST_ARG\" should have failed but passed. $NC"
    exit -1
  else
    exit 0
  fi
}

xmllint_test() {
  find -L ./bazel-testlogs -iname "*.xml" | xargs -n1 xmllint > /dev/null
}

multiple_junit_suffixes() {
  bazel test //test:JunitMultipleSuffixes

  matches=$(grep -c -e 'Discovered classes' -e 'scala.test.junit.JunitSuffixIT' -e 'scala.test.junit.JunitSuffixE2E' ./bazel-testlogs/test/JunitMultipleSuffixes/test.log)
  if [ $matches -eq 3 ]; then
    return 0
  else
    return 1
  fi
}

multiple_junit_prefixes() {
  bazel test //test:JunitMultiplePrefixes

  matches=$(grep -c -e 'Discovered classes' -e 'scala.test.junit.TestJunitCustomPrefix' -e 'scala.test.junit.OtherCustomPrefixJunit' ./bazel-testlogs/test/JunitMultiplePrefixes/test.log)
  if [ $matches -eq 3 ]; then
    return 0
  else
    return 1
  fi
}

multiple_junit_patterns() {
  bazel test //test:JunitPrefixesAndSuffixes
  matches=$(grep -c -e 'Discovered classes' -e 'scala.test.junit.TestJunitCustomPrefix' -e 'scala.test.junit.JunitSuffixE2E' ./bazel-testlogs/test/JunitPrefixesAndSuffixes/test.log)
  if [ $matches -eq 3 ]; then
    return 0
  else
    return 1
  fi
}

junit_generates_xml_logs() {
  bazel test //test:JunitTestWithDeps
  matches=$(grep -c -e "testcase name='hasCompileTimeDependencies'" -e "testcase name='hasRuntimeDependencies'" ./bazel-testlogs/test/JunitTestWithDeps/test.xml)
  if [ $matches -eq 2 ]; then
    return 0
  else
    return 1
  fi
  test -e 
}

test_junit_test_must_have_prefix_or_suffix() {
  action_should_fail test test_expect_failure/scala_junit_test:no_prefix_or_suffix
}

test_junit_test_errors_when_no_tests_found() {
  action_should_fail test test_expect_failure/scala_junit_test:no_tests_found
}

test_resources() {
  RESOURCE_NAME="resource.txt"
  TARGET=$1
  OUTPUT_JAR="bazel-bin/test/src/main/scala/scala/test/resources/$TARGET.jar"
  FULL_TARGET="test/src/main/scala/scala/test/resources/$TARGET.jar"
  bazel build $FULL_TARGET
  jar tf $OUTPUT_JAR | grep $RESOURCE_NAME
}

scala_library_jar_without_srcs_must_include_direct_file_resources(){
  test_resources "noSrcsWithDirectFileResources"
}

scala_library_jar_without_srcs_must_include_filegroup_resources(){
  test_resources "noSrcsWithFilegroupResources"
}

scala_library_jar_without_srcs_must_fail_on_mismatching_resource_strip_prefix() {
  action_should_fail build test_expect_failure/wrong_resource_strip_prefix:noSrcsJarWithWrongStripPrefix
}

scala_test_test_filters() {
    # test package wildcard (both)
    local output=$(bazel test \
                         --cache_test_results=no \
                         --test_output streamed \
                         --test_filter scala.test.* \
                         test:TestFilterTests)
    if [[ $output != *"tests a"* || $output != *"tests b"* ]]; then
        echo "Should have contained test output from both test filter test a and b"
        exit 1
    fi
    # test just one
    local output=$(bazel test \
                         --cache_test_results=no \
                         --test_output streamed \
                         --test_filter scala.test.TestFilterTestA \
                         test:TestFilterTests)
    if [[ $output != *"tests a"* || $output == *"tests b"* ]]; then
        echo "Should have only contained test output from test filter test a"
        exit 1
    fi
}

scala_junit_test_test_filter(){
  local output=$(bazel test \
    --nocache_test_results \
    --test_output=streamed \
    '--test_filter=scala.test.junit.FirstFilterTest#(method1|method2)$|scala.test.junit.SecondFilterTest#(method2|method3)$' \
    test:JunitFilterTest)
  local expected=(
      "scala.test.junit.FirstFilterTest#method1"
      "scala.test.junit.FirstFilterTest#method2"
      "scala.test.junit.SecondFilterTest#method2"
      "scala.test.junit.SecondFilterTest#method3")
  local unexpected=(
      "scala.test.junit.FirstFilterTest#method3"
      "scala.test.junit.SecondFilterTest#method1"
      "scala.test.junit.ThirdFilterTest#method1"
      "scala.test.junit.ThirdFilterTest#method2"
      "scala.test.junit.ThirdFilterTest#method3")
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

scalac_jvm_flags_are_configured(){
  action_should_fail build //test_expect_failure/compilers_jvm_flags:can_configure_jvm_flags_for_scalac
}

javac_jvm_flags_are_configured(){
  action_should_fail build //test_expect_failure/compilers_jvm_flags:can_configure_jvm_flags_for_javac
}

if [ "$1" != "ci" ]; then
  runner="run_test_local"
else
  runner="run_test_ci"
fi

$runner bazel build test/...
$runner bazel test test/...
$runner bazel test plugin/...
$runner bazel run test/src/main/scala/scala/test/twitter_scrooge:justscrooges
$runner bazel run test:JavaBinary
$runner bazel run test:JavaBinary2
$runner bazel run test:MixJavaScalaLibBinary
$runner bazel run test:MixJavaScalaSrcjarLibBinary
$runner bazel run test:ScalaBinary
$runner bazel run test:ScalaLibBinary
$runner test_disappearing_class
$runner find -L ./bazel-testlogs -iname "*.xml"
$runner xmllint_test
$runner test_build_is_identical
$runner test_transitive_deps
$runner test_scala_library_suite
$runner test_repl
$runner bazel run test:JavaOnlySources
$runner test_benchmark_jmh
$runner multiple_junit_suffixes
$runner multiple_junit_prefixes
$runner test_scala_junit_test_can_fail
$runner junit_generates_xml_logs
$runner scala_library_jar_without_srcs_must_fail_on_mismatching_resource_strip_prefix
$runner multiple_junit_patterns
$runner test_junit_test_must_have_prefix_or_suffix
$runner test_junit_test_errors_when_no_tests_found
$runner scala_library_jar_without_srcs_must_include_direct_file_resources
$runner scala_library_jar_without_srcs_must_include_filegroup_resources
$runner bazel run test/src/main/scala/scala/test/large_classpath:largeClasspath
$runner scala_test_test_filters
$runner scala_junit_test_test_filter
$runner scalac_jvm_flags_are_configured
$runner javac_jvm_flags_are_configured
$runner test_scala_library_expect_failure_on_missing_direct_deps
