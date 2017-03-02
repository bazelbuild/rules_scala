#!/bin/bash

set -e

test_disappearing_class() {
  # back up
  cp test_expect_failure/disappearing_class/ClassProvider.scala ClassProvider.scala.tmp
  bazel build test_expect_failure/disappearing_class:uses_class
  echo -e "package scala.test\n\nobject BackgroundNoise{}" > test_expect_failure/disappearing_class/ClassProvider.scala
  set +e
  bazel build test_expect_failure/disappearing_class:uses_class
  RET=$?
  # restore
  cp  ClassProvider.scala.tmp test_expect_failure/disappearing_class/ClassProvider.scala
  rm -f ClassProvider.scala.tmp
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

test_repl() {
  bazel build test:HelloLibRepl
  echo "_____=========================="
  cat bazel-bin/test/HelloLibRepl 
  echo "____=========================="
  echo "import scala.test._; HelloLib.printMessage(\"foo\")" | bazel-bin/test/HelloLibRepl | grep "foo java"
  #echo "import scala.test._; TestUtil.foo" | bazel-bin/test/HelloLibTestRepl | grep "bar" &&
  #echo "import scala.test._; ScalaLibBinary.main(Array())" | bazel-bin/test/ScalaLibBinaryRepl | grep "A hui hou" &&
  #echo "import scala.test._; MoreScalaLibBinary.main(Array())" | bazel-bin/test/MoreScalaLibBinaryRepl | grep "More Hello"
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

run_test $@


