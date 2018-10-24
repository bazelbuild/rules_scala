#!/usr/bin/env bash

echoerr() {
  echo "$@" 1>&2;
}

assert() {
  $@ || (echoerr "FAILED: $@"; exit 1)
}

exists() {
  [ -e $1 ]
}

test_scala_library_outputs_mixed_java_scala_jars() {
  set -e

  TARGET="MixJavaScalaLib"

  bazel build test:"$TARGET"

  assert exists "bazel-bin/test/${TARGET}.jar"
  assert exists "bazel-bin/test/${TARGET}_java.jar"
}

test_scala_library_outputs_mixed_java_scala_jars
