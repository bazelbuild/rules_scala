#!/bin/bash

set -e

test_disappearing_class() {
  git checkout test/src/main/scala/scala/test/disappearing_class/ClassProvider.scala
  bazel build test/src/main/scala/scala/test/disappearing_class:uses_class
  echo -e "package scala.test\n\nobject BackgroundNoise{}" > test/src/main/scala/scala/test/disappearing_class/ClassProvider.scala
  set +e
  bazel build test/src/main/scala/scala/test/disappearing_class:uses_class
  RET=$?
  git checkout test/src/main/scala/scala/test/disappearing_class/ClassProvider.scala
  if [ $RET -eq 0 ]; then
    echo "Class caching at play. This should fail"
    exit 1
  fi
  set -e
}

bazel build test/... \
  && bazel run test:ScalaBinary \
  && bazel run test:ScalaLibBinary \
  && bazel run test:JavaBinary \
  && bazel test test/... \
  && find -L ./bazel-testlogs -iname "*.xml" \
  && (find -L ./bazel-testlogs -iname "*.xml" | xargs -n1 xmllint > /dev/null) \
  && test_disappearing_class \
  && echo "all good"
