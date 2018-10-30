#!/usr/bin/env bash

echoerr() {
  echo "$@" 1>&2;
}

test_scala_library_outputs_mixed_java_scala_jars() {
  set -e

  TARGET="MixJavaScalaLib"
  TEST_TARGET="MixJavaScalaLibTestRule"
  TEST_STDOUT="$(bazel build test:"$TEST_TARGET" 2>&1)"

  grep -q "DEBUG:.*test/${TARGET}.jar" <<< "$TEST_STDOUT" || \
    (echoerr "FAILED: checking for output test/${TARGET}.jar"; exit 1)

  grep -q "DEBUG:.*test/${TARGET}_java.jar" <<< "$TEST_STDOUT" || \
    (echoerr "FAILED: checking for output test/${TARGET}_java.jar"; exit 1)
}

test_scala_library_outputs_mixed_java_scala_jars
