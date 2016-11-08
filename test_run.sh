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

test_build_is_identical() {
  bazel build test/...
  md5sum bazel-bin/test/*.jar > hash1
  bazel clean
  bazel build test/...
  md5sum bazel-bin/test/*.jar > hash2
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

test_repl() {
  echo "import scala.test._; HelloLib.printMessage(\"foo\")" | bazel-bin/test/HelloLibRepl | grep "foo java" &&
  echo "import scala.test._; TestUtil.foo" | bazel-bin/test/HelloLibTestRepl | grep "bar" &&
  echo "import scala.test._; ScalaLibBinary.main(Array())" | bazel-bin/test/ScalaLibBinaryRepl | grep "A hui hou"
}

NC='\033[0m'
GREEN='\033[0;32m'
RED='\033[0;31m'

function run_test() {
  set +e
  TEST_ARG=$@
  echo "running test $TEST_ARG"
  RES=$($TEST_ARG 2>&1)
  RESPONSE_CODE=$?
  if [ $RESPONSE_CODE -eq 0 ]; then
    echo -e "${GREEN} Test $TEST_ARG successful $NC"
  else
    echo $RES
    echo -e "${RED} Test $TEST_ARG failed $NC"
    exit $RESPONSE_CODE
  fi
}

xmllint_test() {
  find -L ./bazel-testlogs -iname "*.xml" | xargs -n1 xmllint > /dev/null
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
run_test test_repl

