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
  set +e

  bazel build test_expect_failure/scala_library_suite:library_suite_dep_on_children
  if [ $? -eq 0 ]; then
    echo "'bazel build test_expect_failure/scala_library_suite:library_suite_dep_on_children' should have failed."
    exit 1
  fi
  set -e
  exit 0
}

test_scala_junit_test_can_fail() {
  set +e

  bazel test test_expect_failure/scala_junit_test:failing_test
  if [ $? -eq 0 ]; then
    echo "'bazel build test_expect_failure/scala_junit_test:failing_test' should have failed."
    exit 1
  fi
  set -e
  exit 0
}

test_repl() {
  echo "import scala.test._; HelloLib.printMessage(\"foo\")" | bazel-bin/test/HelloLibRepl | grep "foo java" &&
  echo "import scala.test._; TestUtil.foo" | bazel-bin/test/HelloLibTestRepl | grep "bar" &&
  echo "import scala.test._; ScalaLibBinary.main(Array())" | bazel-bin/test/ScalaLibBinaryRepl | grep "A hui hou" &&
  echo "import scala.test._; MoreScalaLibBinary.main(Array())" | bazel-bin/test/MoreScalaLibBinaryRepl | grep "More Hello"
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

function run_test() {
  set +e
  SECONDS=0
  TEST_ARG=$@
  echo "running test $TEST_ARG"
  RES=$($TEST_ARG 2>&1)
  RESPONSE_CODE=$?
  DURATION=$SECONDS
  if [ $RESPONSE_CODE -eq 0 ]; then
    echo -e "${GREEN} Test $TEST_ARG successful ($DURATION sec) $NC"
  else
    echo "$RES"
    echo -e "${RED} Test $TEST_ARG failed $NC ($DURATION sec) $NC"
    exit $RESPONSE_CODE
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
  test -e ./bazel-testlogs/test/JunitTestWithDeps/test.xml
}

test_junit_test_must_have_prefix_or_suffix() {
  set +e

  bazel test test_expect_failure/scala_junit_test:no_prefix_or_suffix
  if [ $? -eq 0 ]; then
    echo "'bazel build test_expect_failure/scala_junit_test:no_prefix_or_suffix' should have failed."
    exit 1
  fi
  set -e
  exit 0
}

test_junit_test_errors_when_no_tests_found() {
  set +e

  bazel test test_expect_failure/scala_junit_test:no_tests_found
  if [ $? -eq 0 ]; then
    echo "'bazel build test_expect_failure/scala_junit_test:no_tests_found' should have failed."
    exit 1
  fi
  set -e
  exit 0
}

test_resources() {
  RESOURCE_NAME="resource.txt"
  OUTPUT_JAR="bazel-bin/test/src/main/scala/scala/test/resources/$TARGET.jar"
  FULL_TARGET="test/src/main/scala/scala/test/resources/$TARGET.jar"
  bazel build $FULL_TARGET
  jar tf $OUTPUT_JAR | grep $RESOURCE_NAME
  RET=$?
  if [ $RET -ne 0 ]; then
    echo "Missing ${RESOURCE_NAME} in jar based on $JAR_DESCRIPTION"
    exit 1
  fi
}

scala_library_jar_with_srcs_includes_direct_file_resources(){
  TARGET="yesSrcsResources" \
  JAR_DESCRIPTION="scala_library with srcs" \
  test_resources
}

scala_library_jar_without_srcs_includes_direct_file_resources(){
  TARGET="noSrcsResources" \
  JAR_DESCRIPTION="scala_library without srcs" \
  test_resources
}

scala_library_jar_with_srcs_includes_filegroup_resources(){
  TARGET="yesSrcsFilegroupResources" \
  JAR_DESCRIPTION="scala_library with filegroup resources and without srcs" \
  test_resources
}

scala_library_jar_without_srcs_includes_filegroup_resources(){
  TARGET="noSrcsFilegroupResources" \
  JAR_DESCRIPTION="scala_library with filegroup resources and without srcs" \
  test_resources
}

run_test bazel build test/...
run_test bazel test test/...
run_test bazel run test/src/main/scala/scala/test/twitter_scrooge:justscrooges
run_test bazel run test:JavaBinary
run_test bazel run test:JavaBinary2
run_test bazel run test:MixJavaScalaLibBinary
run_test bazel run test:MixJavaScalaSrcjarLibBinary
run_test bazel run test:ScalaBinary
run_test bazel run test:ScalaLibBinary
run_test test_disappearing_class
run_test find -L ./bazel-testlogs -iname "*.xml"
run_test xmllint_test
run_test test_build_is_identical
run_test test_transitive_deps
run_test test_scala_library_suite
run_test test_repl
run_test bazel run test:JavaOnlySources
run_test test_benchmark_jmh
run_test multiple_junit_suffixes
run_test multiple_junit_prefixes
run_test test_scala_junit_test_can_fail
run_test junit_generates_xml_logs
run_test multiple_junit_patterns
run_test test_junit_test_must_have_prefix_or_suffix
run_test test_junit_test_errors_when_no_tests_found
run_test scala_library_jar_with_srcs_includes_direct_file_resources
run_test scala_library_jar_without_srcs_includes_direct_file_resources
run_test scala_library_jar_with_srcs_includes_filegroup_resources
run_test scala_library_jar_without_srcs_includes_filegroup_resources
