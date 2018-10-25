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

output_contains() {
  grep '{"id":{"targetCompleted' $1 | grep $2 > /dev/null
}

test_scala_library_outputs_mixed_java_scala_jars() {
  set -e

  TARGET="MixJavaScalaLib"
  BUILD_EVENT_FILE="build_event.json"

  bazel build test:"$TARGET" --build_event_json_file=$BUILD_EVENT_FILE

  assert exists "bazel-bin/test/${TARGET}.jar"
  assert exists "bazel-bin/test/${TARGET}_java.jar"

  assert output_contains $BUILD_EVENT_FILE test/${TARGET}.jar
  assert output_contains $BUILD_EVENT_FILE test/${TARGET}_java.jar

  rm $BUILD_EVENT_FILE
}

test_scala_library_outputs_mixed_java_scala_jars
