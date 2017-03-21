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
    echo $RES
    echo -e "${RED} Test $TEST_ARG failed $NC ($DURATION sec) $NC"
    exit $RESPONSE_CODE
  fi
}

xmllint_test() {
  find -L ./bazel-testlogs -iname "*.xml" | xargs -n1 xmllint > /dev/null
}

multiple_junit_suffixes() {
  bazel test //test:JunitMultipleSuffixes
  matches=$(grep -c -e 'Running E2E' -e 'Running IT' ./bazel-testlogs/test/JunitMultipleSuffixes/test.log)
  if [ $matches -eq 2 ]; then
    return 0
  else
    return 1
  fi
}

junit_generates_xml_logs() {
  bazel test //test:JunitTestWithDeps
  test -e ./bazel-testlogs/test/JunitTestWithDeps/test.xml
}

run_test bazel build test/...
run_test bazel test test/...
run_test bazel run test/src/main/scala/scala/test/twitter_scrooge:justscrooges
run_test bazel run test:JavaBinary
run_test bazel run test:JavaBinary2
run_test bazel run test:MixJavaScalaLibBinary
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
run_test test_scala_junit_test_can_fail
run_test junit_generates_xml_logs
